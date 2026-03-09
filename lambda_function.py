#!/usr/bin/env python3
"""
AWS Lambda function to convert TIFF to Cloud Optimized GeoTIFF (COG)
This function runs entirely within AWS Free Tier limits
"""

import os
import tempfile
import boto3
import rasterio
from rio_cogeo.cogeo import cog_translate
from rio_cogeo.profiles import cog_profiles
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    logger.info("=" * 50)  # ← FIXED: changed = to (
    logger.info("COG CONVERSION LAMBDA STARTED")
    logger.info("=" * 50)  # ← FIXED: changed = to (
    
    try:
        # Get file info from S3 event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        logger.info(f"Processing: s3://{bucket}/{key}")
        
        # Create temp directory
        with tempfile.TemporaryDirectory() as tmpdir:
            input_path = os.path.join(tmpdir, 'input.tif')
            output_path = os.path.join(tmpdir, 'output_cog.tif')
            
            # Download from S3
            logger.info("Downloading from S3...")
            s3_client.download_file(bucket, key, input_path)
            
            # Convert to COG
            logger.info("Converting to Cloud Optimized GeoTIFF...")
            profile = cog_profiles.get("deflate")
            cog_translate(input_path, output_path, profile, in_memory=False)
            
            # Upload COG back to S3
            output_key = key.replace('input/', 'output/').replace('.tif', '_cog.tif')
            logger.info(f"Uploading to s3://{bucket}/{output_key}")
            s3_client.upload_file(output_path, bucket, output_key)
            
            logger.info("✅ Conversion complete!")
            
            return {
                'statusCode': 200,
                'body': f'Successfully converted {key} to COG'
            }
            
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
