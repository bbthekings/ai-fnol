// params
param location string = 'germanywestcentral' // default region
param stFnolPilotName string = 'storagefnolpilot' 

// vars
var stFnolPilotNameUnique = '${stFnolPilotName}${uniqueString(resourceGroup().id)}' 

// storage account -> blob service -> container
resource stFnolPilot 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  
  name: stFnolPilotNameUnique
  location:  location
  sku: { 
    name: 'Standard_LRS'
  }
   kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// blobService
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' = {
    parent: stFnolPilot
    name: 'default' // This must always be named 'default'
}

// container
resource pilotContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = {
    parent: blobService
    name: 'pilot-uploads' // folder name
    properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = stFnolPilot.name
output blobServiceName string = blobService.name
output containerName string = pilotContainer.name
output blobEndpoint string = stFnolPilot.properties.primaryEndpoints.blob
