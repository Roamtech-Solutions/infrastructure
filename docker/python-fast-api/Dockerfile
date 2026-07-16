ARG ENVIRONMENT=development
ARG PYTHON_VERSION=3.13
ARG OUR_PYTHON_VERSION=${PYTHON_VERSION}

# -- Stage 1: Base build stage
FROM python:${PYTHON_VERSION}-slim AS builder
ARG OUR_PYTHON_VERSION
ARG ENVIRONMENT

# -- Create the app directory
RUN mkdir /app

# -- Set the working directory
WORKDIR /app

# -- Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# -- APT Dependencies -- #
RUN apt update
RUN apt install -y pkg-config libgirepository-2.0-dev default-libmysqlclient-dev build-essential libcairo2-dev python3-dev

# -- Upgrade pip and install dependencies
RUN pip install --upgrade pip

# -- Copy the requirements file first (better caching)
COPY requirements /app/requirements

# -- Install Python dependencies
RUN pip install --no-cache-dir -r requirements/${ENVIRONMENT}.txt
RUN ls -la /usr/local/lib/python${OUR_PYTHON_VERSION}/site-packages

# -- Stage 2: Production stage
FROM python:${PYTHON_VERSION}-slim
ARG OUR_PYTHON_VERSION=3.10

RUN useradd -m -r appuser && \
   mkdir /app && \
   chown -R appuser /app

# -- gunicorn manages worker processes; uvicorn workers give it ASGI support
RUN pip install gunicorn uvicorn

# -- Copy the Python dependencies from the builder stage
COPY --from=builder /usr/local/lib/python${OUR_PYTHON_VERSION}/site-packages/ /usr/local/lib/python${OUR_PYTHON_VERSION}/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# -- Set the working directory
WORKDIR /app

# -- Copy application code
COPY --chown=appuser:appuser . .

# -- Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# -- Switch to non-root user
USER appuser

# --- Expose the application port
EXPOSE 8080

# -- Start the application using Gunicorn with Uvicorn workers
# -- "app:app" assumes the FastAPI instance is named `app` in `app.py`;
# -- adjust to match the service's actual module:attribute if different
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "3", "-k", "uvicorn.workers.UvicornWorker", "app:app"]
