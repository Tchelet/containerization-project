# Use the official Python image from the Docker Hub
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file from the root directory into the container
COPY ../requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Copy the frontend code into the container
COPY . /app/frontend

# Set environment variable for Flask
ENV FLASK_APP=frontend/app.py

# Specify the command to run on container start
CMD ["python", "frontend/app.py"]