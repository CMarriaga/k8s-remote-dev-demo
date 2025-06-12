import os
import asyncio
import inspect
import aiofiles
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from src.db import check_db_ready, init_db_pool, close_db_pool, fetch_all_users
from src.sqs import send_message_to_sqs, poll_sqs_messages
from src.utils import configure_logging, log_message, extract_trace_id

load_dotenv()

DEBUG_APP_MODE = bool(os.getenv("DEBUG_APP_MODE"))
LOG_APP_PROBES = bool(os.getenv("LOG_APP_PROBES"))
POD_NAME = os.getenv("POD_NAME")
VERSION = os.getenv("VERSION")
DB_URL = os.getenv("DB_URL") #"postgresql://demo_user:demo_pass@db/demo"
db_pool = None

print(f"DB_URL: {DB_URL}")
print(f"VERSION: {VERSION}")

if DEBUG_APP_MODE:
  AWS_ROLE_ARN = os.getenv("AWS_ROLE_ARN")
  AWS_WEB_IDENTITY_TOKEN_FILE = os.getenv("AWS_WEB_IDENTITY_TOKEN_FILE")
  print(f"AWS_ROLE_ARN: {AWS_ROLE_ARN}")
  print(f"AWS_WEB_IDENTITY_TOKEN_FILE: {AWS_WEB_IDENTITY_TOKEN_FILE}")
  print(LOG_APP_PROBES)
  print(DEBUG_APP_MODE)

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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE and LOG_APP_PROBES)
  if bool(LOG_APP_PROBES): 
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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE and LOG_APP_PROBES)
  try:
    await check_db_ready(db_pool)
    if bool(LOG_APP_PROBES): 
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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
  log_message(ctx=ctx, msg="ok", trace_id=trace_id)
  return {
    "success": True,
    "data": {
      "message": "Running"
    }
  }
  
@app.post("/init-db")
async def init_db_endpoint(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
  sql_file_path = os.path.join(os.path.dirname(__file__), "init.sql")
  try:
    # Read the SQL file asynchronously
    async with aiofiles.open(sql_file_path, mode="r") as f:
      sql_content = await f.read()
    # Execute the SQL statements
    async with db_pool.acquire() as conn:
      await conn.execute(sql_content)
    log_message(ctx=ctx, msg="Database initialized from init.sql", trace_id=trace_id)
    return {
      "success": True,
      "data": {
        "message": "Database initialized from init.sql"
      }
    }
  except Exception as e:
    log_message(ctx=ctx, exc=e, trace_id=trace_id)
    response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    return {
      "success": False,
      "error": "Failed to initialize database"
    }

@app.get("/title")
async def get_title(request: Request, response: Response):
  ctx = inspect.currentframe().f_code.co_name
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
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
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
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

# Catch-all route for non-existent paths (wildcard route)
@app.api_route("/{full_path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def catch_all(request: Request, response: Response, full_path: str):
  # Capture the 404 error, log it, and respond to the user
  trace_id = extract_trace_id(request, DEBUG_APP_MODE)
  log_message(
    ctx="catch_all",
    msg=f"404 Not Found: {request.method} /{full_path}",
    trace_id=trace_id
  )
  response.status_code=status.HTTP_404_NOT_FOUND
  return {
    "success": False,
    "data": {
    "message": "Resource not found"
    }
  }