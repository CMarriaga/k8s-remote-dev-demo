# ---------- Build Stage ----------
FROM python:3.11-slim as builder

WORKDIR /app

# Install build tools for native deps like asyncpg and uvloop
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install dependencies into a temp dir
COPY requirements.txt .
RUN pip install --upgrade pip && \
  pip install --no-cache-dir --target=/python_deps -r requirements.txt

# Copy app code
COPY ./src /app/src

# ---------- Final Stage ----------
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

# Copy installed packages and app code from builder
COPY --from=builder /python_deps /app/python_deps
COPY --from=builder /app/src /app/src

# Copy entrypoint
COPY /entrypoint.py /app/entrypoint.py

ENV PYTHONPATH="/app/python_deps"
ENV MODULE_NAME=src.main
ENV HOST=0.0.0.0
ENV PORT=8000
ENV WORKERS=1
ENV ENVIRONMENT=production

# Use Python script as entrypoint (no shell required)
ENTRYPOINT ["python3", "/app/entrypoint.py"]
