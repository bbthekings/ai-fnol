# runtime = python interp
FROM python:3.13-slim
WORKDIR /app

# 1. Capture the value during build
ARG VERSION_ARG
# 2. Save it permanently into the image environment
ENV MODEL_VERSION=$VERSION_ARG

# Install the application dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# gh action: The model was downloaded to ./app/model/fnol-risk-model/model.pkl
# We copy it into the root of the /app container directory
COPY model.pkl ./model.pkl

# Copy-in the source code
COPY src/score/app.py ./app.py

# run the web service on container="0.0.0.0"/port="8080"
EXPOSE 8000
# The path to the FastAPI instance is app:app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]