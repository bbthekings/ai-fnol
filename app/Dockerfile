# runtime = python interp
FROM python:3.13-slim
WORKDIR /app

# Install the application dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy-in the source code
COPY src/score/app.py ./app.py

# run the web service on container="0.0.0.0"/port="8080"
EXPOSE 8000
# The path to the FastAPI instance is app:app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]