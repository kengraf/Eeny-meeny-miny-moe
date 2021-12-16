# Eeny-meeny-miny-moe
Random selection of a student to present next in class  

Motivation is to demonstrate a simple cloud deployment. Cloud is great but, to be frank checkmarks on the class roster would be easier.  
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

### LAMBDA
AWS CLI to create a Lambda function require files for packages, roles, and policies.  The example here assume you have clone this Github repo and have the proper working diectory

Create role for Lambda function
```
aws iam create-role --role-name EenyMeenyMinyMoeLambdaRole --assume-role-policy-document file://lambdatrustpolicy.json
```
Attach policy for DynamoDB access to role
```
aws iam put-role-policy --role-name EenyMeenyMinyMoeLambdaRole --policy-name LambdaDynamoDBAccessPolicy --policy-document file://lambdapolicy.json
```
Create Lambda
```
aws lambda create-function --function-name EenyMeenyMinyMoe \
    --runtime nodejs14.x \
    --zip-file function.zip \
    --role EenyMeenyMinyMoeLambdaRole
```

### Create API
```
aws apigateway create-rest-api --name 'EenyMeenyMinyMoe' > output
APIID=`cat output | jq -r '.id'`
aws apigateway get-resources --rest-api-id $APIID > output
PARENTID=`cat output | jq -r '.items[].id'`
aws apigateway create-resource --rest-api-id $APIID --parent-id $PARENTID --path-part Moe > output
RESOURCEID=`cat output | jq -r '.id'`
aws apigateway put-method --rest-api-id $APIID --resource-id $RESOURCEID --http-method GET --authorization-type "NONE"
aws apigateway put-method-response --rest-api-id $APIID --resource-id $RESOURCEID \
  --http-method GET --status-code 200
aws apigateway put-integration --rest-api-id $APIID \
--resource-id $RESOURCEID --http-method GET --type AWS \
--integration-http-method GET \
--uri arn:aws:apigateway:us-west-2:lambda:path//2015-03-31/functions/arn:aws:lambda:us-west-2:123412341234:function:function_name/invocations'
arn:aws:lambda:us-east-2:788715698479:function:EenyMeenyMinyMoe

aws apigateway create-deployment --rest-api-id $APIID --stage-name prod
```

### Clean Up
Delete DynamoDB table
```
aws dynamodb delete-table --table-name EenyMeenyMinyMoe
```
Delete Role and Policy
```
aws iam delete-role-policy --role-name EenyMeenyMinyMoeLambdaRole --policy-name LambdaDynamoDBAccessPolicy
aws iam delete-role --role-name EenyMeenyMinyMoeLambdaRole
```
Delete Lambda function
```
```

Remove all the resources created

