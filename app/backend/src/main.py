import os
from fastapi import FastAPI, Response, status, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from src.db import check_db_ready, init_db_pool, close_db_pool, fetch_all_users
from src.sqs import send_message_to_sqs
from src.utils import configure_logging, log_message

DB_URL = os.getenv("DB_URL") #"postgresql://demo_user:demo_pass@db/demo"
db_pool = None

configure_logging() 

@asynccontextmanager
async def lifespan(app: FastAPI):
  global db_pool
  #db_pool = await init_db_pool(dsn=DB_URL)
  log_message("Database pool created")
  
  yield
  #await close_db_pool()
  log_message("Database pool closed")

app = FastAPI(lifespan=lifespan)

app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],  
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)

@app.get("/healthz")
def health():
  return {
    "success": True,
    "data": {
      "message": "ok"
    }
  }

@app.get("/readyz")
async def ready(response: Response):
  try:
    await check_db_ready(db_pool)
    return {
      "success": True,
      "data": {
        "message": "ok"
      }
    }
  except Exception as e:
    log_message("readyz", e)
    response.status_code=status.HTTP_503_SERVICE_UNAVAILABLE
    return {
      "error": "Readiness check failed",
      "success": False
    }

@app.get("/users")
async def list_users(response: Response):
  try:
    users = await fetch_all_users()
    return {
      "success": True,
      "data": users
    }
  except Exception as e:
    log_message("list_users", e)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "success": False,
      "error": "Could not retrieve users"
    }

@app.post("/send-sqs")
async def send_sqs(response: Response):
  try:
    send_message_to_sqs("This is a test message from backend")
    return {
      "success": True,
      "data": {
        "message": "Sent to SQS"
      }
    }
  except Exception as e:
    log_message("send_sqs", e)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "error": "Failed to send message",
      "success": False
    }

@app.get("/debug")
async def debug_endpoint(response: Response):
  try:
    return {
      "success": True,
      "data": {
        "message": "Debug endpoint called"
       }
    }
  except Exception as e:
    log_message("debug_endpoint", e)
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "error": "Debug failed",
      "success": False
    }
