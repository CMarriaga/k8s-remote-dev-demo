import boto3
import os
from botocore.exceptions import BotoCoreError, ClientError
from src.utils import log_message

# Recommended: set AWS_REGION via env vars or use IRSA
REGION = os.getenv("AWS_REGION", "us-east-1")
QUEUE_URL = os.getenv("SQS_QUEUE_URL")

# Create SQS client (use default credentials chain: env vars, IAM, etc.)
sqs = boto3.client("sqs", region_name=REGION)

def send_message_to_sqs(message_body: str):
  if not QUEUE_URL:
    log_message(Exception("SQS_QUEUE_URL not set"), "send_message_to_sqs")
    return

  try:
    response = sqs.send_message(
      QueueUrl=QUEUE_URL,
      MessageBody=message_body,
    )
    return response
  except (BotoCoreError, ClientError) as e:
    log_message(e, "send_message_to_sqs")
