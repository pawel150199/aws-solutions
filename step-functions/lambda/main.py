import boto3
import json
import os
import logging
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
sns = boto3.client("sns")


def configure_logger():
    """Configure logger"""
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    return logger


def create_file(logger, s3_bucket, s3_filename, content):
    """Create example file in S3 bucket"""
    try:
        s3_filepath = "/tmp/" + s3_filename
        with open(s3_filepath, "w") as f:
            f.write(content)
        s3.upload_file(s3_filepath, s3_bucket, s3_filename)
        logger.info("File has been successfully uploaded")
    except ClientError as e:
        logger.error(e)


def lambda_handler(event, context):
    # Configure logger
    logger = configure_logger()

    s3_bucket = os.getenv("S3_BUCKET")
    s3_filename = os.getenv("S3_FILENAME")

    if not s3_bucket:
        raise ValueError("The S3 bucket is not set")

    if not s3_filename:
        raise ValueError("The S3 filename is not set")

    content = event["content"]

    try:
        create_file(logger, s3_bucket, s3_filename, content)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "S3 file has been succesfuly created"}),
        }

    except Exception as e:
        logger.error(str(e))
        return {"statusCode": 500, "body": f"Error: {str(e)}"}
