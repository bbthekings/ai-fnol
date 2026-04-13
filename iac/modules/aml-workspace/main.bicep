
param amlWorkspaceName string = 'aml-fnol-wspace'
param location string = 'germanywestcentral'

param storageAccountId string
param keyVaultId string
// param appInsightsId string
// param containerRegistryId string


resource amlFnolWspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  
  name: amlWorkspaceName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  
  // link to storage account
properties: {
    friendlyName: 'FNOL Pilot Machine Learning Workspace'
    publicNetworkAccess: 'Enabled'
    // Linking the foundational resources: 
    // establish a Hard Dependency and Service-to-Service configuration
    storageAccount: storageAccountId
    keyVault: keyVaultId
    // applicationInsights: appInsightsId
    // containerRegistry: containerRegistryId
    // Basic settings for a Pilot
    // hbiWorkspace: false // Set to true if handling highly sensitive data
  }
}

output amlWorkspaceId string = amlFnolWspace.id
output amlWorkspaceNameOut string = amlFnolWspace.name

