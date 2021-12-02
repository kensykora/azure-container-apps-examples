resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'helloqueuestg'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource queueService 'queueServices' = {
    name: 'default'
    
    resource queue 'queues' = {
      name: 'processorqueue'
    }
  }
}

resource nodeApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'hello-queue-capp'

  location: resourceGroup().location
  properties: {
    kubeEnvironmentId: '/subscriptions/0f2e944e-87ec-4915-89ad-e53520f9e52d/resourceGroups/hello-world-abcd/providers/Microsoft.Web/kubeEnvironments/hello-world-abcd-env'
    configuration: {
      // ingress: {
      //   external: true
      //   targetPort: 3000
      // }
      secrets: [
        {
          name: 'connection-string'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'   
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'kensykora/azure-queue-processor:latest'
          name: 'azure-queue-processor'
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'AZURE_STORAGE_CONNECTION_STRING'
              secretref: 'connection-string'
            }
            {
              name: 'AZURE_STORAGE_QUEUE_NAME'
              value: storage::queueService::queue.name
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'queue-rule'
            azureQueue: {
              queueName: storage::queueService::queue.name
              queueLength: 5
              auth: [
                {
                    secretRef: 'connection-string'
                    triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
      dapr: {
        enabled: false
      }
    }
  }
}
