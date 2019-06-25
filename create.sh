#!/bin/bash
set -e

# Set this to something unique. It is going to be the prefix for the bucket
# names. The name is set to PARENT_STACK-AWS::Region
STACK_SET_NAME=

REGIONS=$(aws ec2 describe-regions --output text --query Regions[*].RegionName)

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

# Currently, StackSets are not supported in these regions. This may change over time.
REGIONS=${REGIONS//eu-north-1/}
REGIONS=${REGIONS//ap-northeast-3/}

# This is used for testing the stack in a single region
# aws cloudformation create-stack \
#   --stack-name $STACK_SET_NAME \
#   --region ap-south-1 \
#   --template-body file://stack.cfn.yml \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --parameters \
#   ParameterKey=BucketPrefix,ParameterValue=$STACK_SET_NAME

# Create the StackSet
aws cloudformation create-stack-set \
  --stack-set-name $STACK_SET_NAME \
  --template-body file://stack.cfn.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
  ParameterKey=BucketPrefix,ParameterValue=$STACK_SET_NAME

# Launch the Stack Instances in the defined region
aws cloudformation create-stack-instances \
  --stack-set-name $STACK_SET_NAME \
  --accounts $ACCOUNT_ID \
  --regions $REGIONS

