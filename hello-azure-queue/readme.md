```bash
# Docker build
docker build -t kensykora/azure-queue-processor .

# Run Locally
# NOTE: Connection string must be replaced in ../.env file
docker run --env-file ../.env kensykora/azure-queue-processor

# Create a resource group for the deployment
az group create -n hello-queue -l CanadaCentral
# Create the deployment
az deployment group create -g hello-queue --template-file infra.bicep

# Watch example for monitoring scaling
watch az containerapp revision show -g dapr-hello-example --app dapr-hello-example-app-node -n dapr-hello-example-app-node--0wl5n54
```