#!/bin/bash

# Edit the following parameters to suit your needs.  
# The S3 bucket needs to be globally unique
STACK=eeny2025
S3BUCKET=eeny2025
REGION=us-east-2
EMAIL="your.email@example.com"

if aws s3api head-bucket --bucket "$S3BUCKET" --region ${REGION} 2>/dev/null; then
  echo "Bucket '$S3BUCKET' exists."
else
  echo "Creating bucket '$S3BUCKET'."
  aws s3api create-bucket --bucket ${S3BUCKET} --region ${REGION}  --create-bucket-configuration LocationConstraint=${REGION}
fi
    
echo "Load lambda and friends to S3 bucket..."
zip eeny2025.zip -xi eeny2025.py
aws s3 cp eeny2025.zip s3://${S3BUCKET}
aws s3 cp friends s3://${S3BUCKET}

echo "Creating stack..."
# upload cf stack
STACK_ID=`aws cloudformation deploy --stack-name ${STACK} \
  --template-file eeny2025.yaml --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides  S3bucket=$S3BUCKET Email=${EMAIL} \
  --region ${REGION} --query "StackId" --output text`

aws cloudformation list-exports --query "Exports[?Name=='eeny2025-FetchFunctionUrl'].Value" --output text
