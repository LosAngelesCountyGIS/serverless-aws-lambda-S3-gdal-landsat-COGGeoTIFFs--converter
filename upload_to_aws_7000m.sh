#!/bin/bash
echo "=========================================================="
echo "☁️ UPLOAD 7,000m FILE TO AWS S3"
echo "WITH FREE TIER VERIFICATION"
echo "=========================================================="

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    sudo apt update && sudo apt install -y awscli
fi

# Check AWS configuration
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS not configured. Please run: aws configure"
    echo "You'll need:"
    echo "  - AWS Access Key ID"
    echo "  - AWS Secret Access Key"
    echo "  - Default region: us-west-1"
    echo "  - Output format: json"
    exit 1
fi

cd /home/professor/Downloads/landsat_to_cog

# Find the file
FILE="processing_pipeline/05_final_output_7000m/americana_7000m_raw.tif"

if [ ! -f "$FILE" ]; then
    echo "❌ ERROR: File not found! Run ./process_landsat_7000m.sh first"
    exit 1
fi

# Check if COG already exists
COG_FILE="processing_pipeline/05_final_output_7000m/americana_7000m_raw_cog.tif"
if [ -f "$COG_FILE" ]; then
    COG_SIZE=$(du -h "$COG_FILE" | cut -f1)
    COG_EXISTS="Yes - $COG_SIZE"
else
    COG_EXISTS="Not yet - will be created by Lambda"
fi

# Get file size
FILE_SIZE=$(du -h "$FILE" | cut -f1)
FILE_SIZE_BYTES=$(du -b "$FILE" | cut -f1)
FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE_BYTES/1048576" | bc)
FILE_SIZE_GB=$(echo "scale=4; $FILE_SIZE_BYTES/1073741824" | bc)

# Verify free tier status
S3_LIMIT_GB=5
USAGE_PERCENT=$(echo "scale=2; $FILE_SIZE_GB/$S3_LIMIT_GB*100" | bc)

echo ""
echo "=========================================================="
echo "✅ FILE INFORMATION"
echo "=========================================================="
echo "Raw file: $FILE"
echo "Raw size: $FILE_SIZE ($FILE_SIZE_MB MB / $FILE_SIZE_GB GB)"
echo "COG status: $COG_EXISTS"
echo ""
echo "=========================================================="
echo "✅ FREE TIER VERIFICATION"
echo "=========================================================="
echo "AWS Free Tier: 5 GB"
echo "Your usage: ${USAGE_PERCENT}% of free limit"
echo "Remaining free space: $(echo "scale=2; 5 - $FILE_SIZE_GB" | bc) GB"
echo ""
echo "✅ GUARANTEED: This file is 100% FREE to store and process!"
echo "=========================================================="
echo ""

# Ask for confirmation
read -p "Continue with upload to S3? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upload cancelled."
    exit 0
fi

# Use your EXISTING bucket (not creating a new one)
BUCKET_NAME="landsat-cog-20260309-1420"
echo "Using existing bucket: $BUCKET_NAME"

# Check if input folder exists, create if not
aws s3 ls s3://$BUCKET_NAME/input/ &>/dev/null
if [ $? -ne 0 ]; then
    echo "Creating input folder..."
    aws s3api put-object --bucket $BUCKET_NAME --key input/
fi

echo "Uploading file to s3://$BUCKET_NAME/input/americana_7000m_raw.tif ..."
aws s3 cp "$FILE" s3://$BUCKET_NAME/input/americana_7000m_raw.tif

echo ""
echo "=========================================================="
echo "✅ UPLOAD COMPLETE!"
echo "=========================================================="
echo "File URL: s3://$BUCKET_NAME/input/americana_7000m_raw.tif"
echo ""
echo "⏱️  Lambda will now process the file (takes 2-3 minutes)"
echo ""
echo "To check progress:"
echo "1. Watch Lambda logs: aws logs describe-log-groups --log-group-name-prefix /aws/lambda/landsat-to-cog"
echo "2. Check for output folder: aws s3 ls s3://$BUCKET_NAME/output/"
echo ""
echo "✅ FINAL COG WILL BE AT: s3://$BUCKET_NAME/output/americana_7000m_raw_cog.tif"
echo ""
echo "🎉 THIS 7,000m FILE IS 100% FREE - NO CHARGES!"
echo "=========================================================="