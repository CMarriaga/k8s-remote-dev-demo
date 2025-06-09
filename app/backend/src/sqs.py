import boto3
import asyncio
import aioboto3
import os
import inspect
from dotenv import load_dotenv
from botocore.exceptions import BotoCoreError, ClientError
from src.utils import log_message

load_dotenv()

# Recommended: set AWS_REGION via env vars or use IRSA
REGION = os.getenv("AWS_REGION", "us-east-1")
QUEUE_URL = os.getenv("SQS_QUEUE_URL")
DEBUG_APP_MODE = os.getenv("DEBUG_APP_MODE")

# Create SQS client (use default credentials chain: env vars, IAM, etc.)
sqs = boto3.client("sqs", region_name=REGION)

last_messages = {
  "limit": 10,
  "messages": []
}

def send_message_to_sqs(message_body: str):
  ctx = inspect.currentframe().f_code.co_name
  if not QUEUE_URL:
    log_message(ctx=ctx, exc=Exception("SQS_QUEUE_URL not set"))
    return
  try:
    response = sqs.send_message(
      QueueUrl=QUEUE_URL,
      MessageBody=message_body,
    )
    return response
  except (BotoCoreError, ClientError) as e:
    log_message(ctx=ctx, exc=e)

def update_last_messages(message):
  if len(last_messages["messages"]) < last_messages["limit"]:
    last_messages["messages"].append(message)
  else:
    last_messages["messages"].pop()
    last_messages["messages"].append(message)

async def poll_sqs_messages():
  ctx = inspect.currentframe().f_code.co_name
  aio_sqs = aioboto3.Session()
  async with aio_sqs.client("sqs", region_name=REGION) as sqs:
    while True:
      try:
        response = await sqs.receive_message(
          QueueUrl=QUEUE_URL,
          MaxNumberOfMessages=10,
          WaitTimeSeconds=20
        )
        messages = response.get("Messages", [])
        for msg in messages:
          if bool(DEBUG_APP_MODE): 
            log_message(ctx=ctx, msg=f'[sqs_received]: {msg["Body"]}')
          update_last_messages(msg)
          # Delete after processing
          await sqs.delete_message(
            QueueUrl=QUEUE_URL,
            ReceiptHandle=msg["ReceiptHandle"]
          )
      except Exception as e:
        log_message(ctx=ctx, exc=e)
      await asyncio.sleep(1)
