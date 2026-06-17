# Step 1: Use an official lightweight Python image
FROM python:3.11-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy just the requirements first (optimizes Docker caching)
COPY requirements.txt .

# Step 4: Install the Python dependencies
RUN pip install --no-cache-dir --no-cache-dir -r requirements.txt

# Step 5: Copy the rest of your project files into the container
COPY . .

# Step 6: Create non-root user for security
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

# Step 7: Expose the port Gunicorn will run on
EXPOSE 8000

# Step 8: Run Gunicorn in production mode with security settings
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "--worker-class", "sync", "--max-requests", "1000", "--max-requests-jitter", "100", "--timeout", "30", "--forwarded-allow-ips", "*", "app:app"]
