from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from src.db import init_db, get_users, check_db_ready
from src.sqs import send_message_to_sqs
from src.utils import configure_logging, log_error

configure_logging() 

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield

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
    return {"status": "ok"}

@app.get("/readyz")
async def ready():
    try:
        is_ready = await check_db_ready()
        return {"status": "ready" if is_ready else "not ready"}
    except Exception as e:
        log_error(e, "readyz")
        return JSONResponse(status_code=503, content={"error": "Readiness check failed"})

@app.get("/users")
async def list_users():
    try:
        users = await get_users()
        return users
    except Exception as e:
        log_error(e, "list_users")
        return JSONResponse(status_code=500, content={"error": "Could not retrieve users"})

@app.post("/send-sqs")
async def send_sqs():
    try:
        send_message_to_sqs("This is a test message from backend")
        return {"message": "Sent to SQS"}
    except Exception as e:
        log_error(e, "send_sqs")
        return JSONResponse(status_code=500, content={"error": "Failed to send message"})

@app.get("/debug")
async def debug_endpoint():
    try:
        return {"message": "Debug endpoint called"}
    except Exception as e:
        log_error(e, "debug_endpoint")
        return JSONResponse(status_code=500, content={"error": "Debug failed"})
