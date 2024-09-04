#!/bin/bash

# Pull the latest changes from the repo
git pull origin main

# Build the containers
docker-compose build
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting." | tee build_failure.log
    exit 1
fi

# Stop the current containers
docker-compose down

# Start the new containers
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Deployment failed. Exiting." | tee deploy_failure.log
    exit 1
fi

# Perform health checks
curl -f http://localhost:8000/ || echo "Frontend health check failed." >> health_check.log
curl -f http://localhost:5000/ || echo "Backend health check failed." >> health_check.log

echo "CI/CD process completed successfully."