# Eeny-meeny-miny-moe
Random selection of a student to present next in class  

Motivation of this repo is to demonstrate a simple cloud deployment. Cloud is great but to be frank paper and pencil checkmarks on the class roster would be easier.  
This example leverages AWS DynamoDB, Lambda, and Cognito.

### DynamoDB
Create a new table named `EenyMeenyMinyMoe`
```
aws dynamodb create-table \
    --table-name EenyMeenyMinyMoe \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Owner,Value=Teacher
```
    
Add student records for testing.  
```
students=("Alice" "Bob" "Charlie")
for i in "${students[@]}"
do
   : 
  aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
    '{ "Name": {"S": "'$i'"}, "Pickable": {"BOOL": true}  }' 
done
```

### Lambda
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
aws iam list-roles \
    --query 'Roles[?RoleName==`EenyMeenyMinyMoe`].Arn' > output
ARN=`cat output | cut -d '"'  -f 2 -s`
aws lambda create-function --function-name EenyMeenyMinyMoe \
    --runtime nodejs14.x --role $ARN \
    --zip-file fileb://function.zip \
    --runtime nodejs14.x --handler exports.handler \
```

### API Gateway
```
aws apigateway create-rest-api --name 'EenyMeenyMinyMoe'
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
PARENTID=`aws apigateway get-resources --rest-api-id $APIID \
    --query 'items[0].id' --output text`
RESOURCEID=`aws apigateway create-resource --rest-api-id $APIID \
    --parent-id $PARENTID --path-part Moe \
    --query "id" --output text`
```
Create a GET method for a Lambda-proxy integration
```
aws apigateway put-method --rest-api-id $APIID \
    --resource-id $RESOURCEID --http-method GET \
    --authorization-type "NONE"
aws apigateway put-method-response --rest-api-id $APIID \
    --resource-id $RESOURCEID \
    --http-method GET --status-code 200
ARN=`aws lambda get-function --function-name EenyMeenyMinyMoe \
    --query Configuration.FunctionArn --output text`
REGION=`aws ec2 describe-availability-zones --output text \
    --query 'AvailabilityZones[0].[RegionName]'`
URI='arn:aws:apigateway:'$REGION':lambda:path/2015-03-31/functions/'$ARN'/invocations'
aws apigateway put-integration --rest-api-id $APIID \
   --resource-id $RESOURCEID --http-method GET --type AWS_PROXY \
   --integration-http-method GET --uri $URI
aws apigateway put-integration-response --rest-api-id $APIID \
    --resource-id $RESOURCEID \
    --http-method GET \
    --status-code 200 \
    --selection-pattern "" 
aws apigateway create-deployment --rest-api-id $APIID --stage-name prod

curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/prod/Moe
```

### Clean Up
Delete DynamoDB table
```
aws dynamodb delete-table --table-name EenyMeenyMinyMoe
```
Delete Role and Policy
```
aws iam list-policies --scope Local \
    --query 'Policies[?PolicyName==`LambdaDynamoDBAccessPolicy`].Arn' > output
ARN=`cat output | cut -d '"'  -f 2 -s`
aws iam detach-role-policy --role-name EenyMeenyMinyMoeLambda --policy-arn $ARN
aws iam delete-role-policy --role-name EenyMeenyMinyMoeLambda --policy-name LambdaDynamoDBAccessPolicy
aws iam delete-role --role-name EenyMeenyMinyMoeLambdaRole
aws iam delete-policy  --policy-arn $ARN
```
Delete Lambda function
```
aws lambda list-functions \
    --query 'Functions[?FunctionName==`EenyMeenyMinyMoe`]'
aws lambda delete-function --function-name EenyMeenyMinyMoe
```
Delete API Gateway
```
aws apigateway get-resources --rest-api-id cctgmqw3c5
aws apigateway get-integration --rest-api-id $APIID --resource-id $PARENTID --http-method Post
```

Remove all the resources created

