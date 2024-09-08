#!/bin/bash

# Ensure the VERSION file exists
if [ ! -f VERSION ]; then
    echo "1.0.0" > VERSION
fi

# Load the current version from the VERSION file
VERSION=$(cat VERSION)

# Define the Docker image name
IMAGE_NAME="your-dockerhub-username/containerization-project"

# Export the VERSION variable so it can be used by docker-compose
export VERSION

# Pull the latest changes from the repo
git pull origin main

# Build the containers with the current version tag
docker-compose build
if [ $? -ne 0 ]; then
    echo "Build failed. Exiting." | tee build_failure.log
    exit 1
fi

# Tag the images for the dev environment
docker tag $IMAGE_NAME-backend:$VERSION $IMAGE_NAME-backend:dev
docker tag $IMAGE_NAME-frontend:$VERSION $IMAGE_NAME-frontend:dev

# Push the images to Docker Hub for the dev environment
docker push $IMAGE_NAME-backend:dev
docker push $IMAGE_NAME-frontend:dev

# Stop and remove any existing containers
docker-compose down --remove-orphans

# Start the new containers
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "Deployment failed. Exiting." | tee deploy_failure.log
    exit 1
fi

# Perform health checks
curl -f http://localhost:8000/ || echo "Frontend health check failed." >> health_check.log
curl -f http://localhost:5000/ || echo "Backend health check failed." >> health_check.log

# If health checks pass, tag the images for the prod environment
if [ ! -s health_check.log ]; then
    docker tag $IMAGE_NAME-backend:$VERSION $IMAGE_NAME-backend:prod
    docker tag $IMAGE_NAME-frontend:$VERSION $IMAGE_NAME-frontend:prod

    # Push the images to Docker Hub for the prod environment
    docker push $IMAGE_NAME-backend:prod
    docker push $IMAGE_NAME-frontend:prod

    # Increment the version number (simple example, you might want to use a more sophisticated versioning strategy)
    IFS='.' read -r -a VERSION_PARTS <<< "$VERSION"
    VERSION_PARTS[2]=$((VERSION_PARTS[2] + 1))
    NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}"

    # Update the VERSION file with the new version
    echo $NEW_VERSION > VERSION

    # Commit the new version to the repository
    git add VERSION
    git commit -m "Bump version to $NEW_VERSION"
    git push origin main

    echo "CI/CD process completed successfully. New version is $NEW_VERSION."
else
    echo "Health checks failed. Check health_check.log for details."
    exit 1
fi