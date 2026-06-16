# Step 1: Use an official lightweight Python image
FROM python:3.11-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy just the requirements first (optimizes Docker caching)
COPY requirements.txt .

# Step 4: Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Step 5: Copy the rest of your project files into the container
COPY . .

# Step 6: Expose the port Gunicorn will run on
EXPOSE 8000

# Step 7: Run Gunicorn in production mode
# Original : CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "app:app"]
