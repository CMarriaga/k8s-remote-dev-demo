# Use slim Python base
FROM python:3.11-slim

# Set env vars
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY ./src/ ./src/

# Default envs
ENV MODULE_NAME=src.main
ENV HOST=0.0.0.0
ENV PORT=8000
ENV WORKERS=1
ENV ENVIRONMENT=production

# Entry point
CMD ["/bin/sh", "-c", "\
    if [ \"$ENVIRONMENT\" = 'development' ]; then \
        uvicorn $MODULE_NAME:app --host $HOST --port $PORT --reload; \
    else \
        gunicorn -k uvicorn.workers.UvicornWorker $MODULE_NAME:app --workers $WORKERS --bind $HOST:$PORT; \
    fi"]