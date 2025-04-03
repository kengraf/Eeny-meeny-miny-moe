#!/bin/bash

# Edit the following parameters to suit your needs.  
# The S3 bucket needs to be globally unique
STACK=eeny2025
S3BUCKET=eeny-2025
REGION=us-east-2

if aws s3api head-bucket --bucket "$S3BUCKET" --region ${REGION} 2>/dev/null; then
  echo "Bucket '$S3BUCKET' exists."
else
  echo "Creating bucket '$S3BUCKET'."
  aws s3api create-bucket --bucket ${S3BUCKET} --region ${REGION}
fi
    
echo "Load lambda and friends to S3 bucket..."
zip eeny.zip -xi eeny.py
aws s3 cp eeny.zip s3://${S3BUCKET}
aws s3 cp friends s3://${S#BUCKET}

echo "Creating stack..."
# upload cf stack
STACK_ID=`aws cloudformation deploy --stack-name ${STACK} \
  --template-body file://cfStack2025.yaml --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=DeployName,Value=${STACK} \
  --region ${REGION} --query "StackId" --output text`

aws cloudformation list-exports --query "Exports[?Name=='EENY2025_URL'].Value" --output text
