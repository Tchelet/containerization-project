# Use the official Python image from the Docker Hub
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file from the root directory into the container
COPY ../requirements.txt .

# Install the dependencies
RUN pip install -r requirements.txt

# Copy the backend code into the container
COPY . .

# Expose port 5000 for the backend service
EXPOSE 5000

# Specify the command to run on container start
CMD ["python", "app.py"]