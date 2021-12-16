# Eeny-meeny-miny-moe
Random selection of a student to present next in class  

Motivation is to demonstrate a simple cloud deployment. Cloud is great but, to be frank checkmarks on the class roster would be easier.  
This example leverages AWS DynamoDB, Lambda, and Cognito.

### DynamoDB
Create a new table named `EenyMeanyMinyMoe`
```aws dynamodb create-table \
    --table-name EenyMeanyMinyMoe \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Owner,Value=Teacher
```
    
Add student records for testing.  We like `Alice, Bob, and Charlie`
```
students=("Alice" "Bob" "Charlie")
for i in "${students[@]}"
do
   : 
  aws dynamodb put-item --table-name EenyMeanyMinyMoe --item \
    '{ "Name": {"S": "'$i'"}, "Picked": {"BOOL": false}  }' 
done
```
