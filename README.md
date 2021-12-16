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

Create role for Lambda function to access DynamoDB `EenyMeenyMinyMoeRole`
```
aws iam create-policy --policy-name LambdaDynamoDBAccessPolicy --policy-document file://lambdapolicy.json
aws iam create-role --role-name EenyMeenyMinyMoeLambdaRole --assume-role-policy-document file://lambdatrustpolicy.json


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:*"
        }
    ]
}
```

```
aws iam create-role --role-name NeenyMeenyMinyMoeLambdaRole \
  --assume-role-policy-document <value>
```
