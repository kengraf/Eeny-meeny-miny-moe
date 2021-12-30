# Eeny-meeny-miny-moe
A child might use this game/process to select from a group of friends.

Thing of this repo as simple, yet complete, Cloud deployment to replicate that child-like game.

This deployment leverages AWS DynamoDB, Lambda, and Cognito.  Clone this repo and use the Cloud shell to issue the commands.
```
git clone https://github.com/kengraf/Eeny-meeny-miny-moe.git
cd Eeny-meeny-miny-moe
```

General process
1) Drop a set of "friend's names" into DynamoDB
2) Invoke a lambda to pick a friend
3) Repeat until you run out of friends

### DynamoDB: used to store your friends
Create a new table named `EenyMeenyMinyMoe`
```
aws dynamodb create-table \
    --table-name EenyMeenyMinyMoe \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    
```
    
Add friend records for testing.  
```
friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
    '{ "Name": {"S": "'$i'"} }' 
done

```

### Lambda: used to select a friend
AWS CLI to create a Lambda function require files for packages, roles, and policies.  The example here assume you have clone this Github repo and are in the proper working diectory

Create role for Lambda function
```
aws iam create-role --role-name EenyMeenyMinyMoe \
    --assume-role-policy-document file://lambdatrustpolicy.json
```
Attach policy for DynamoDB access to role
```
aws iam put-role-policy --role-name EenyMeenyMinyMoe \
    --policy-name EenyMeenyMinyMoe \
    --policy-document file://lambdapolicy.json
```
Create Lambda
```
zip function.zip -xi index.js
ARN=`aws iam list-roles --output text \
    --query "Roles[?RoleName=='EenyMeenyMinyMoe'].Arn" `
aws lambda create-function --function-name EenyMeenyMinyMoe \
    --runtime nodejs14.x --role $ARN \
    --zip-file fileb://function.zip \
    --runtime nodejs14.x --handler index.handler
aws lambda add-permission \
    --function-name EenyMeenyMinyMoe \
    --action lambda:InvokeFunction \
    --statement-id apigateway \
    --principal apigateway.amazonaws.com
```

### API Gateway
```
aws apigateway create-rest-api --name 'EenyMeenyMinyMoe' \
    --endpoint-configuration types=REGIONAL
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
PARENTID=`aws apigateway get-resources --rest-api-id $APIID \
    --query 'items[0].id' --output text`

# Create a GET method for a Lambda-proxy integration
aws apigateway put-method --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --authorization-type "NONE"
            
ARN=`aws lambda get-function --function-name EenyMeenyMinyMoe \
    --query Configuration.FunctionArn --output text`
REGION=`aws ec2 describe-availability-zones --output text \
    --query 'AvailabilityZones[0].[RegionName]'`
URI='arn:aws:apigateway:'$REGION':lambda:path/2015-03-31/functions/'$ARN'/invocations'
aws apigateway put-integration --rest-api-id $APIID \
   --resource-id $PARENTID --http-method GET --type AWS_PROXY \
   --integration-http-method POST --uri $URI
   
aws apigateway put-integration-response --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --status-code 200 --selection-pattern "" 
aws apigateway create-deployment --rest-api-id $APIID --stage-name prod
```

Set permission for Gateway to call Lambda
```
aws lambda add-permission \
--function-name EenyMeenyMinyMoe \
--statement-id AllowGateway \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com 
```

Does it work?
```
curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/prod/
```

### Clean Up
```
# Delete API Gateway
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
aws apigateway get-resources --rest-api-id $APIID
aws apigateway get-integration --rest-api-id $APIID --resource-id $PARENTID --http-method Post

# Delete Lambda function
aws lambda delete-function --function-name EenyMeenyMinyMoe

# Delete DynamoDB table
aws dynamodb delete-table --table-name EenyMeenyMinyMoe

# Delete Role and Policy
ARN=`aws iam list-policies --scope Local --output text \
    --query "Policies[?PolicyName=='LambdaDynamoDBAccessPolicy'].Arn" `
aws iam detach-role-policy --role-name EenyMeenyMinyMoeLambda \
    --policy-arn $ARN
aws iam delete-role-policy --role-name EenyMeenyMinyMoeLambda \
    --policy-name LambdaDynamoDBAccessPolicy
aws iam delete-role --role-name EenyMeenyMinyMoeLambdaRole
aws iam delete-policy  --policy-arn $ARN
```

Remove all the resources created

