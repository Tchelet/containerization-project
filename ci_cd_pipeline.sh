#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the directory of the script
SCRIPT_DIR=$(dirname "$0")

# Variables
DOCKER_COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# Check if VERSION file exists and is not empty
if [[ ! -f "$SCRIPT_DIR/VERSION" || ! -s "$SCRIPT_DIR/VERSION" ]]; then
  echo "VERSION file is missing or empty. Please create a VERSION file with a valid version string."
  exit 1
fi

# Read the VERSION file
VERSION=$(cat "$SCRIPT_DIR/VERSION")
echo "VERSION: $VERSION"

# Export the VERSION variable so it is available to docker-compose
export VERSION

# Build the Docker images with semantic versioning tags
echo "Building Docker images..."
VERSION=$VERSION docker-compose -f "$DOCKER_COMPOSE_FILE" build

# Tag the images with the version
echo "Tagging Docker images..."
docker tag tchelet/containerization-project-backend:$VERSION tchelet/containerization-project-backend:$VERSION
docker tag tchelet/containerization-project-frontend:$VERSION tchelet/containerization-project-frontend:$VERSION

# Deploy the application
echo "Deploying application..."
VERSION=$VERSION docker-compose -f "$DOCKER_COMPOSE_FILE" up -d

# Monitor the services
echo "Monitoring services..."
docker-compose -f "$DOCKER_COMPOSE_FILE" ps

# Cleanup
echo "Cleaning up..."
rm -rf "$SCRIPT_DIR/$PROJECT_DIR"

echo "CI/CD pipeline completed successfully!"