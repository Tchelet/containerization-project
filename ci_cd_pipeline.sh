#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
REPO_URL="https://github.com/Tchelet/containerization-project.git"
PROJECT_DIR="containerization-project"
DOCKER_COMPOSE_FILE="docker-compose.yml"
VERSION=$(cat VERSION)

# Clone the repository
echo "Cloning repository..."
git clone $REPO_URL
cd $PROJECT_DIR

# Build the Docker images with semantic versioning tags
echo "Building Docker images..."
docker-compose -f $DOCKER_COMPOSE_FILE build --build-arg VERSION=$VERSION

# Tag the images
echo "Tagging Docker images..."
docker tag tchelet/containerization-project-backend:latest your-dockerhub-username/containerization-project-backend:$VERSION
docker tag tchelet/containerization-project-frontend:latest your-dockerhub-username/containerization-project-frontend:$VERSION

# Run tests (assuming you have a test script or command)
echo "Running tests..."
# Example: docker-compose -f $DOCKER_COMPOSE_FILE run backend pytest
# Replace with your actual test command
docker-compose -f $DOCKER_COMPOSE_FILE run backend pytest

# Deploy the application
echo "Deploying application..."
docker-compose -f $DOCKER_COMPOSE_FILE up -d

# Monitor the services
echo "Monitoring services..."
docker-compose -f $DOCKER_COMPOSE_FILE ps

# Cleanup
echo "Cleaning up..."
cd ..
rm -rf $PROJECT_DIR

echo "CI/CD pipeline completed successfully!"