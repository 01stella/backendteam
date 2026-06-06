FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# For now, just run the script once when the container boots
CMD ["python", "-u", "main.py"]