@description('The suffix applied to all resources')
param applicationSuffix string = uniqueString(resourceGroup().id)

@description('The name given to the Azure Cognitive Search Resource')
param searchServiceName string = 'acs-${applicationSuffix}'

@description('The name given to the Azure AI service')
param azureAIServiceName string = 'azai-${applicationSuffix}'

@description('The name given to the Azure Storage Account')
param storageAccountName string = 'sa${applicationSuffix}'

@description('The name given to the blob container')
param containerName string = 'hotels-container'

@description('The location for all resources. Default is the location of the resource group.')
param location string = resourceGroup().location

@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
@description('The pricing tier of the search service you want to create (for example, basic or standard).')
param searchServiceSku string = 'basic'

@allowed([
  'S0'
])
param azureAISku string = 'S0'

@description('Replicas distribute search workloads across the service. You need at least two replicas to support high availability of query workloads (not applicable to the free tier).')
@minValue(1)
@maxValue(12)
param replicaCount int = 1

@description('Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple search units.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

resource search 'Microsoft.Search/searchServices@2022-09-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: searchServiceSku
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: azureAIServiceName
  location: location
  sku: {
    name: azureAISku
  }
  kind: 'CognitiveServices'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/${containerName}'
}
