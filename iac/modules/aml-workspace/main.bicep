
param amlWorkspaceName string
param location string

param storageAccountName string
param storageAccountId string
param keyVaultId string
param applInsightsId string
param containerRegistryId string

var amlWorkspaceNameUnique string = take( '${amlWorkspaceName}${uniqueString(resourceGroup().id)}' , 24)


resource amlFnolWspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  
  name: amlWorkspaceNameUnique
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  identity: {
    type: 'SystemAssigned' // CRITICAL: Allows the workspace to talk to the Key Vault
  }
// link to storage account, keyvault, container registry, appl insights
properties: {
    friendlyName: 'FNOL Pilot Machine Learning Workspace'
    publicNetworkAccess: 'Enabled'
    // Linking the foundational resources: 
    // establish a Hard Dependency and Service-to-Service configuration
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applInsightsId
    containerRegistry: containerRegistryId
    // Basic settings for a Pilot
    hbiWorkspace: false // Set to true if handling highly sensitive data
  }
}

// Define the storage as a child of the Workspace
resource pilotUploadsDatastore 'Microsoft.MachineLearningServices/workspaces/datastores@2023-04-01' = {
  parent: amlFnolWspace
  name: 'ds_pilot_uploads' 
  properties: {
    description: 'Datastore for FNOL pilot upload parquet files'
    datastoreType: 'AzureBlob'
    accountName: storageAccountName
    containerName: 'pilot-uploads'
    endpoint: environment().suffixes.storage // 'core.windows.net'
    protocol: 'https'
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
    credentials: {
      credentialsType: 'None'
    }
  }
}

output amlWorkspaceId string = amlFnolWspace.id
output amlWorkspaceNameOut string = amlFnolWspace.name
output pilotUploadsDatastoreId string = pilotUploadsDatastore.id

