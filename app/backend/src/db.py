import asyncpg
from src.utils import log_message


db_pool = None  # Global reference

async def init_db_pool(dsn: str):
  global db_pool
  db_pool = await asyncpg.create_pool(dsn)
  return db_pool

async def close_db_pool():
  global db_pool
  if db_pool:
    await db_pool.close()

async def get_db():
  async with db_pool.acquire() as connection:
    yield connection
    
async def check_db_ready(pool: asyncpg.Pool):
  async with pool.acquire() as conn:
    await conn.execute("SELECT 1")

async def fetch_all_users(pool: asyncpg.Pool):
  async with pool.acquire() as conn:
    rows = await conn.fetch("SELECT * FROM users")
    return [dict(row) for row in rows]
