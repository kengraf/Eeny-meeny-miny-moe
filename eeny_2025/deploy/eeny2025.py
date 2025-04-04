import json
import boto3
import random
import os

dynamo = boto3.client("dynamodb")
sns = boto3.client("sns")
s3 = boto3.client("s3")
bucket_name = os.environ['BUCKET_NAME'] # set by cloudformation

def reload_data():
    # nuke the curremt content
    response = dynamo.scan(TableName='eeny2025')
    items = response.get("Items", [])
    for item in items:
        key = {k: v for k, v in item.items()}
        dynamo.delete_item(TableName='eeny2025', Key=key)
        
    # Read the friends file and populate
    response = s3.get_object(Bucket=bucket_name, Key="friends")
    lines = response["Body"].read().decode("utf-8").splitlines()
    for l in lines:
        dynamo.put_item( TableName='eeny2025', Item={"Name": {"S": l}}) 
    
def lambda_handler(event, context):
    status_code = 200
    headers = {"Content-Type": "application/json"}
    body = ""
    
    try:
        if event.get("rawPath") == "/reload":
            reload_data()
        elif ( event.get("rawPath") == "/" ):
            result = dynamo.scan(TableName='eeny2025')
            
            if result.get("Count", 0) == 0:
                # Fetch SNS topics
                body = "Game Over"
                reload_data()
            else:
                picked = random.randint(0, result["Count"] - 1)
                body = result["Items"][picked]["Name"]["S"]  # Extract the name
                
                try:
                    response = dynamo.delete_item(
                        TableName="eeny2025",
                        Key={"Name": {"S": body}},
                        ReturnValues='ALL_OLD'
                    )
                    print(response.get("Attributes"))
                except Exception as e:
                    print(e)
        else:
            raise ValueError(f'Unsupported route: "{event.get("routeKey")}" event: {json.dumps(event)}')
    
    except Exception as err:
        status_code = 400
        body = f"Lambda error: {str(err)}"
    
    return {
        "statusCode": status_code,
        "body": body,
        "headers": headers
    }
