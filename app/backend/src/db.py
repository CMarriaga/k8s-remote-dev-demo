import asyncpg
from src.utils import log_error

db = None

async def init_db():
    global db
    try:
      db = await asyncpg.connect(
          user="postgres",
          password="postgres", # Your password
          database="demo",
          host="postgres-service",  # service name in Kubernetes
          port=5432,
      )
    except Exception as e:
      log_error(e, "init_db")

async def get_users():
    global db
    try:
        if db is None:
            raise Exception("Database not initialized")
        return await db.fetch("SELECT id, name, email, city FROM users")
    except Exception as e:
        log_error(e, "get_users")
        return []
  
async def check_db_ready():
    global db
    try:
        if db is None:
            return False
        await db.execute("SELECT 1")
        return True
    except Exception as e:
        log_error(e, "check_db_ready")
        return False