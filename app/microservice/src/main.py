import os
import inspect
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from src.utils import configure_logging, log_message, extract_trace_id

load_dotenv()

DEBUG_APP_MODE = bool(os.getenv("DEBUG_APP_MODE"))
LOG_APP_PROBES = bool(os.getenv("LOG_APP_PROBES"))
POD_NAME = os.getenv("POD_NAME")
VERSION = os.getenv("VERSION")

print(LOG_APP_PROBES)
print(DEBUG_APP_MODE)

configure_logging() 

@asynccontextmanager
async def lifespan(app: FastAPI):
  ctx = inspect.currentframe().f_code.co_name
  log_message(ctx=ctx, msg="Application started")
  yield
  log_message(ctx=ctx, msg="Application stopped")

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