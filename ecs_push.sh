#!/bin/bash

# Variables
AWS_REGION="ap-south-1"  # Change to your desired AWS region
AWS_ACCOUNT_ID="396608769297"  # Replace with your AWS account ID
ECR_REPO_NAME="fastapi-app"  # Replace with your ECR repository name
IMAGE_TAG="latest"  # Change as needed (e.g., app version)

# Prompt for Dockerfile path
read -r -p "Enter the Dockerfile path: " DOCKERFILE_PATH

# Validate Dockerfile path
if [ ! -d "$DOCKERFILE_PATH" ]; then
  echo "❌ Error: Dockerfile path '$DOCKERFILE_PATH' does not exist."
  exit 1
fi

# Authenticate Docker to AWS ECR
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Check if authentication was successful
if [ $? -ne 0 ]; then
  echo "❌ Docker authentication to ECR failed!"
  exit 1
fi

# Build the Docker image
docker build -t "$ECR_REPO_NAME:$IMAGE_TAG" "$DOCKERFILE_PATH"

# Tag the image for ECR
docker tag "$ECR_REPO_NAME:$IMAGE_TAG" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"

# Push the image to ECR
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"

# Confirm success
if [ $? -eq 0 ]; then
  echo "✅ Image pushed successfully to ECR."
else
  echo "❌ Image push failed. Check for errors."
  exit 1
fi
