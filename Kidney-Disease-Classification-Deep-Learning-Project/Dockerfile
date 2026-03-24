FROM python:3.11-slim

RUN apt update -y && apt install curl -y

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR /app

# Copy all application files first (needed for -e . in requirements)
COPY . /app

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt

# Create directory for model files
RUN mkdir -p /app/artifacts

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

CMD ["python3", "app.py"]