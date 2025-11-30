# Cloud Run Multi-Container Communication Example

This repository demonstrates how **multiple containers** (sidecars) of a Cloud Run service can communicate with each other.

It consists of two containers:
1.  **Ingress Container**: The main container that receives external traffic. It runs a Node.js server.
2.  **Sidecar Container**: A helper container that runs a separate Node.js server.

The Ingress container communicates with the Sidecar container using `localhost` or the sidecar's name, as they share the same network namespace.

## Quick Start

You can use the provided script to automatically build and deploy the service:

```bash
./deploy.sh
```

The script will:
1.  Prompt for a region and Artifact Registry repository name.
2.  Create the repository if it doesn't exist.
3.  Build both container images using Cloud Build.
4.  Update `service.yaml` with the correct image paths.
5.  Deploy the service to Cloud Run.
6.  **Invoke the service** using `curl` with an authenticated token.

## Testing

```bash
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" http://YOUR_SERVICE_URL.run.app
```

## Manual Deployment Instructions

### 1. Set up Artifact Registry

Create a Docker repository in Artifact Registry:

```bash
gcloud artifacts repositories create my-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository for Cloud Run multi-container example"
```

### 2. Build Containers with Cloud Build

Build the ingress container:

```bash
gcloud builds submit ingress \
    --tag us-central1-docker.pkg.dev/$(gcloud config get-value project)/my-repo/ingress
```

Build the sidecar container:

```bash
gcloud builds submit sidecar \
    --tag us-central1-docker.pkg.dev/$(gcloud config get-value project)/my-repo/sidecar
```

### 3. Deploy to Cloud Run

Update `service.yaml` with the image paths from the previous step, then deploy:

```bash
gcloud run services replace service.yaml
```
