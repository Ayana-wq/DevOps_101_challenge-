#!/bin/bash

# ===============================
# AWS S3 FULL WORKFLOW SCRIPT
# ===============================

BUCKET_NAME="<bucket-name>"
REGION="us-east-1"
FILE_TO_UPLOAD="sample.txt"

echo "🔹 Creating test file..."
echo "This is a test file for S3 upload." > $FILE_TO_UPLOAD

echo "🔹 Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

echo "🔹 Listing all buckets:"
aws s3 ls

echo "🔹 Uploading file to S3..."
aws s3 cp $FILE_TO_UPLOAD s3://$BUCKET_NAME/

echo "🔹 Listing objects inside bucket:"
aws s3 ls s3://$BUCKET_NAME/

echo "🔹 Syncing local folder to S3..."
mkdir demo-folder
echo "Hello from folder" > demo-folder/test.txt
aws s3 sync demo-folder s3://$BUCKET_NAME/demo/

echo "🔹 Emptying the bucket..."
aws s3 rm s3://$BUCKET_NAME --recursive

echo "🔹 Deleting the bucket..."
aws s3api delete-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

echo "✅ Workflow complete!"
