ARG ENVIRONMENT=development

# Stage 1: Base build stage
FROM python:3.13-slim AS builder
ARG ENVIRONMENT

# -- Create the app directory
RUN mkdir /app

# -- Set the working directory
WORKDIR /app

# -- Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# -- Upgrade pip and install dependencies 
RUN pip install --upgrade pip

# -- Copy the requirements file first (better caching) 
COPY requirements /app/requirements

# -- Install Python dependencies 
RUN pip install --no-cache-dir -r requirements/${ENVIRONMENT}.txt

# -- Stage 2: Production stage
FROM python:3.13-slim

# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN useradd -m -r appuser && \
   mkdir /app && \
   chown -R appuser /app

# -- Copy the Python dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
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

# -- Default command for CLI operations (can be overridden)
ENTRYPOINT ["python", "manage.py"]
CMD ["--help"]

