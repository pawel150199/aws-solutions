import boto3
import json
import os, sys
import logging
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
sns = boto3.client('sns')

def configure_logger():
    """Configure logger"""
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(console_handler)
    return logger


def send_sns_notification(logger, s3_bucket, s3_filename):
    """Send an SNS notification when the file is available in S3"""
    sns_topic_arn = os.getenv('SNS_TOPIC_ARN')
    if not sns_topic_arn:
        raise ValueError("The SNS topic name is not set")
    
    message = f"The file '{s3_filename}' is now available in S3 bucket '{s3_bucket}'."
    subject = "File available in S3"
    
    try:
        sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject=subject
        )
        logger.info("SNS notification has been successfully sent")
    except ClientError as e:
        logger.error(f"Failed to send SNS notification: {e}")
        raise e


def create_file(logger, s3_bucket, s3_filename, content):
    """Create example file in S3 bucket"""
    try:
        with open(s3_filename, "rb") as f:
            f.write(content)
        s3.upload_file(s3_filename, bucket, s3_filename)
        logger.info("File has been successfully uploaded")
    except ClientError as e:
        logger.error("e")


def lambda_handler(event, context):
    # Configure logger
    logger = configure_logger()

    s3_bucket = os.getenv("S3_BUCKET")
    s3_filename = os.getenv("S3_FILENAME")

    if not s3_bucket:
        raise ValueError("The S3 bucket is not set")

    if not s3_filename:
        raise ValueError("The S3 filename is not set")

    content = b"Example content to be uploaded to S3"

    # Connect to the RDS PostgreSQL instance
    try:
        create_file(logger, s3_bucket, s3_filename, content)
        send_sns_notification(logger, s3_bucket, s3_filename)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'S3 file has been succesfuly created'
            })
        }
    
    except Exception as e:
        logger.error(str(e))
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
