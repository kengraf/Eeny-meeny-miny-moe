# Eeny-meeny-miny-moe
A child might use this game/process to select from a group of friends.

We are using this repo to learn about a basic Cloud deployment.

This deployment leverages a database tier (AWS DynamoDB), application (Lambda), and web front end (API Gateway).  Clone this repo and use the Cloud shell to issue the commands.
```
git clone https://github.com/kengraf/Eeny-meeny-miny-moe.git
cd Eeny-meeny-miny-moe
```

General game process
1) Drop a set of "friend's names" into DynamoDB
2) Invoke a lambda to pick a friend
3) Repeat until you run out of friends

### DynamoDB: used to store your friends
```
# Create a new table named `EenyMeenyMinyMoe`
aws dynamodb create-table \
    --table-name EenyMeenyMinyMoe \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    
```
    
```
# Add friend records for testing.  
friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
    '{ "Name": {"S": "'$i'"} }' 
done

```

### Lambda: used to select a friend
AWS CLI to create a Lambda function require files for packages, roles, and policies.  The example here assumes you have cloned this Github repo and are in the proper working directory

```
# Create role for Lambda function
aws iam create-role --role-name EenyMeenyMinyMoe \
    --assume-role-policy-document file://lambdatrustpolicy.json
```
```
# Attach policy for DynamoDB access to role
aws iam put-role-policy --role-name EenyMeenyMinyMoe \
    --policy-name EenyMeenyMinyMoe \
    --policy-document file://lambdapolicy.json
ARN=`aws iam list-roles --output text \
    --query "Roles[?RoleName=='EenyMeenyMinyMoe'].Arn" `
```
```
# Create Lambda
zip function.zip -xi index.js
aws lambda create-function --function-name EenyMeenyMinyMoe \
    --runtime nodejs14.x --role $ARN \
    --zip-file fileb://function.zip \
    --runtime nodejs14.x --handler index.handler
```
```
# Give the API Gateway permission to invoke the Lambda
aws lambda add-permission \
    --function-name EenyMeenyMinyMoe \
    --action lambda:InvokeFunction \
    --statement-id AllowGateway \
    --principal apigateway.amazonaws.com
```

### API Gateway
```
# Create the Gateway
aws apigateway create-rest-api --name 'EenyMeenyMinyMoe' \
    --endpoint-configuration types=REGIONAL
```

```
# Create a GET method for a Lambda-proxy integration
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
PARENTID=`aws apigateway get-resources --rest-api-id $APIID \
    --query 'items[0].id' --output text`
aws apigateway put-method --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --authorization-type "NONE"
            
# Create integration with Lambda
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

# Push out deployment
aws apigateway create-deployment --rest-api-id $APIID --stage-name prod
```

### Run the game.  Each refresh will return a different name.
```
curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/prod/
```

### Clean Up by removing all the resources created
```
# Delete API Gateway
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
aws apigateway delete-rest-api --rest-api-id $APIID

# Delete Lambda function
aws lambda delete-function --function-name EenyMeenyMinyMoe

# Delete DynamoDB table
aws dynamodb delete-table --table-name EenyMeenyMinyMoe

# Delete Role and Policy
aws iam delete-role-policy --role-name EenyMeenyMinyMoe \
    --policy-name EenyMeenyMinyMoe
aws iam delete-role --role-name EenyMeenyMinyMoe 
```

### Extra credit
- Error handling
- Monitoring and alerts
- Add authorization to the API using Cognito
- Use Route53 to provide a friendly domain name for the APIGateway
- Expand the API to allow adding and removing names
