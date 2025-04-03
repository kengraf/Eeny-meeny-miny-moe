import json
import boto3
import random

dynamo = boto3.client("dynamodb")
sns = boto3.client("sns")

def lambda_handler(event, context):
    status_code = 200
    headers = {"Content-Type": "application/json"}
    body = ""
    
    try:
        if event.get("rawPath") == "/":
            result = dynamo.scan(TableName='eeny-redo')
            
            if result.get("Count", 0) == 0:
                # Fetch SNS topics
                body = "Game Over"
            else:
                picked = random.randint(0, result["Count"] - 1)
                body = result["Items"][picked]["Name"]["S"]  # Extract the name
                
                try:
                    response = dynamo.delete_item(
                        TableName="eeny-redo",
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
