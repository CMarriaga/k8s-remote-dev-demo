import os
import asyncio
import inspect
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from src.db import check_db_ready, init_db_pool, close_db_pool, fetch_all_users
from src.sqs import send_message_to_sqs, poll_sqs_messages
from src.utils import configure_logging, log_message, extract_trace_id

load_dotenv()

POD_NAME = os.getenv("POD_NAME")
VERSION = os.getenv("VERSION")
DB_URL = os.getenv("DB_URL") #"postgresql://demo_user:demo_pass@db/demo"
db_pool = None

configure_logging() 

@asynccontextmanager
async def lifespan(app: FastAPI):
  global db_pool
  ctx = inspect.currentframe().f_code.co_name
  db_pool = await init_db_pool(dsn=DB_URL)
  log_message(ctx=ctx, msg="Database pool created")
  sqs_task = asyncio.create_task(poll_sqs_messages())
  yield
  sqs_task.cancel()
  await close_db_pool()
  log_message(ctx=ctx, msg="Database pool closed")

app = FastAPI(lifespan=lifespan)

app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],  
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)

@app.get("/healthz")
def health(request: Request):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  log_message(ctx=ctx, msg="ok", trace_id=trace_id)
  return {
    "success": True,
    "data": {
      "message": "ok"
    }
  }

@app.get("/readyz")
async def ready(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  try:
    await check_db_ready(db_pool)
    log_message(ctx=ctx, msg="ok", trace_id=trace_id)
    return {
      "success": True,
      "data": {
        "message": "ok"
      }
    }
  except Exception as e:
    log_message(ctx=ctx, exc=e, trace_id=trace_id)
    response.status_code=status.HTTP_503_SERVICE_UNAVAILABLE
    return {
      "error": "Readiness check failed",
      "success": False
    }

@app.get("/")
async def running(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  log_message(ctx=ctx, msg="ok", trace_id=trace_id)
  return {
    "success": True,
    "data": {
      "message": "Running"
    }
  }
    
@app.get("/title")
async def get_title(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  log_message(ctx=ctx, msg="ok", trace_id=trace_id)
  return {
    "success": True,
    "data": {
      "message": f"This is running {VERSION} on pod {POD_NAME}"
    }
  }

@app.get("/users")
async def list_users(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  try:
    users = await fetch_all_users(db_pool)
    log_message(ctx=ctx, msg="ok", trace_id=trace_id)
    return {
      "success": True,
      "data": users
    }
  except Exception as e:
    log_message(ctx=ctx, exc=e, trace_id=trace_id)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "success": False,
      "error": "Could not retrieve users"
    }

@app.post("/send-sqs")
async def send_sqs(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  try:
    send_message_to_sqs(f"[trace_id={trace_id}]: This is a test message from backend")
    log_message(ctx=ctx, msg="ok", trace_id=trace_id)
    return {
      "success": True,
      "data": {
        "message": "Sent to SQS"
      }
    }
  except Exception as e:
    log_message(ctx=ctx, exc=e, trace_id=trace_id)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "error": "Failed to send message",
      "success": False
    }

@app.get("/debug")
async def debug_endpoint(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request)
  try:
    log_message(ctx=ctx, msg="ok", trace_id=trace_id)
    return {
      "success": True,
      "data": {
        "message": "Debug endpoint called"
      }
    }
  except Exception as e:
    log_message(ctx=ctx, exc=e, trace_id=trace_id)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "error": "Debug failed",
      "success": False
    }
