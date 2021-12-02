```bash
# Create the resource group
az group create -n dapr-hello-example -l CanadaCentral

# Create the bicep deployment
az deployment group create -g dapr-hello-example --template-file infra.bicep

# See source code:
# https://github.dev/dapr/quickstarts/tree/v1.4.0/hello-kubernetes

# Watch for the scaling example
watch az containerapp revision show -g dapr-hello-example --app dapr-hello-example-app-node -n dapr-hello-example-app-node--0wl5n54
```