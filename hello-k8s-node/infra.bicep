resource logs 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: 'dapr-hello-example-logs'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource env 'Microsoft.Web/kubeEnvironments@2021-03-01' = {
  name: 'dapr-hello-example-env'
  location: resourceGroup().location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logs.properties.customerId
        sharedKey: logs.listKeys().primarySharedKey
      }
    }
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'daprhelloexamplestg'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource nodeApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'dapr-hello-example-app-node'

  location: resourceGroup().location
  properties: {
    kubeEnvironmentId: env.id
    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }
      secrets: [
        {
          name: 'storage-key'
          value: storage.listKeys().keys[0].value
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'dapriosamples/hello-k8s-node:latest'
          name: 'hello-k8s-node'
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
      dapr: {
        enabled: true
        appPort: 3000
        appId: 'nodeapp'
        components: [
          {
            name: 'statestore'
            type: 'state.azure.blobstorage'
            version: 'v1'
            metadata: [
              {
                name: 'accountName'
                value: storage.name
              }
              {
                name: 'accountKey'
                secretRef: 'storage-key'
              }
              {
                name: 'containerName'
                value: 'daprstate'
              }
            ]
          }
        ]
      }
    }
  }
}

resource pythonApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'dapr-hello-example-app-python'

  location: resourceGroup().location
  properties: {
    kubeEnvironmentId: env.id
    configuration: {}
    template: {
      containers: [
        {
          image: 'dapriosamples/hello-k8s-python:latest'
          name: 'hello-k8s-python'
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      dapr: {
        enabled: true
        appId: 'pythonapp'
      }
    }
  }
}
