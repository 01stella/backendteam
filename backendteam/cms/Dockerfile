# Use the official Python image
FROM python:3.10-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install MySQL client dependencies
RUN apt-get update && apt-get install -y default-libmysqlclient-dev build-essential pkg-config

# We will create this requirements file in a second
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the CMS code
COPY . /app/

# Expose the Django port
EXPOSE 8000

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]