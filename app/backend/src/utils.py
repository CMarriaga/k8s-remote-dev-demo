import logging
import json
import sys
from datetime import datetime, timezone

class JsonFormatter(logging.Formatter):
  def format(self, record: logging.LogRecord) -> str:
    log_entry = {
      "ts": datetime.now(timezone.utc).replace(tzinfo=None).isoformat(timespec="milliseconds"),
      "level": record.levelname,
      "pid": record.process,
      "msg": record.getMessage(),
      "ctx": record.__dict__.get("ctx", "log")
    }
    return json.dumps(log_entry)

def configure_logging() -> None:
  handler = logging.StreamHandler(sys.stdout)
  handler.setFormatter(JsonFormatter())

  root = logging.getLogger()
  root.setLevel(logging.INFO)
  root.handlers = [handler]

def log_message(ctx: str = "Unhandled", exc: Exception = None) -> None:
  if exc is None:
    logging.info(f"{ctx}")
  else:
    logging.error(f"{exc}", exc_info=True, extra={"ctx": ctx})