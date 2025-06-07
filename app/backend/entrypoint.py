import os
import subprocess

host = os.getenv("HOST", "0.0.0.0")
port = os.getenv("PORT", "8000")
workers = os.getenv("WORKERS", "1")
module_name = os.getenv("MODULE_NAME", "src.main")

cmd = [
    "python3", "-m", "gunicorn",
    "-k", "uvicorn.workers.UvicornWorker",
    f"{module_name}:app",
    "--workers", workers,
    "--bind", f"{host}:{port}"
]

subprocess.run(cmd)