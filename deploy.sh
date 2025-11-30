#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

# Prompt for Region
read -p "Enter region (default: us-central1): " REGION
REGION=${REGION:-us-central1}
echo "Using region: $REGION"

# Prompt for Repo Name
read -p "Enter Artifact Registry repository name (default: my-repo): " REPO_NAME
REPO_NAME=${REPO_NAME:-my-repo}
echo "Using repository: $REPO_NAME"

echo "Project ID: $PROJECT_ID"

# 1. Set up Artifact Registry
echo "Checking Artifact Registry repository..."
if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION > /dev/null 2>&1; then
    echo "Creating repository $REPO_NAME in $REGION..."
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker repository for Cloud Run multi-container example"
else
    echo "Repository $REPO_NAME already exists in $REGION."
fi

# 2. Build Containers with Cloud Build
echo "Building ingress container..."
gcloud builds submit ingress \
    --tag $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/ingress

echo "Building sidecar container..."
gcloud builds submit sidecar \
    --tag $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/sidecar

# 3. Deploy to Cloud Run
echo "Updating service.yaml with new image paths..."
# Replace image paths dynamically using sed
# We match "image: .*ingress" and replace it with the new full path
sed -i '' "s|image: .*ingress|image: $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/ingress|g" service.yaml
sed -i '' "s|image: .*sidecar|image: $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/sidecar|g" service.yaml

echo "Deploying to Cloud Run..."
gcloud run services replace service.yaml --region $REGION

# 4. Test the Service
echo "Getting service URL..."
SERVICE_URL=$(gcloud run services describe multi-container-service --region $REGION --format 'value(status.url)')

echo "Invoking service at $SERVICE_URL..."
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $SERVICE_URL
