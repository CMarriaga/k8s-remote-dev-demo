import logging
import json
import sys
from fastapi import Request
from datetime import datetime, timezone

def extract_trace_id(request: Request) -> str:
    return request.headers.get("x-b3-traceid", None)

class JsonFormatter(logging.Formatter):
  def format(self, record: logging.LogRecord) -> str:
    log_entry = {
      "ts": datetime.now(timezone.utc).replace(tzinfo=None).isoformat(timespec="milliseconds"),
      "level": record.levelname,
      "pid": record.process,
      "msg": record.getMessage(),
      "ctx": record.__dict__.get("ctx", "log"),
      "trace_id": record.__dict__.get("trace_id", "log")
    }
    return json.dumps(log_entry)

def configure_logging() -> None:
  handler = logging.StreamHandler(sys.stdout)
  handler.setFormatter(JsonFormatter())

  root = logging.getLogger()
  root.setLevel(logging.INFO)
  root.handlers = [handler]

def log_message(ctx: str = "Unhandled", exc: Exception = None, msg: str=None, trace_id: str = None) -> None:
  if exc is None:
    logging.info(f"{msg}", extra={"ctx": ctx, "trace_id": trace_id})
  else:
    logging.error(f"{exc}", exc_info=True, extra={"ctx": ctx, "trace_id": trace_id })