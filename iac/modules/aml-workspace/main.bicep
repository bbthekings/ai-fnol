
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

// create an aml.data-store 'ds_pilot_uploads' that points to storage-account.blob='pilot-uploads'
// access is badge-managed
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

// compute resource 'cpu-cluster' for training
resource mlCompute 'Microsoft.MachineLearningServices/workspaces/computes@2023-04-01' = {
  parent: amlFnolWspace
  name: 'cpu-cluster'
  location: location
  properties: {
  computeType: 'AmlCompute'
  properties: {
    // F-Series is often more available on limited subscriptions
    vmSize: 'Standard_F2s_v2' 
    vmPriority: 'Dedicated' // Use 'Dedicated' to avoid quota conflicts for now
    scaleSettings: {
      maxNodeCount: 1 // Keep it at 1 to stay within tight limits
      minNodeCount: 0
    }
  }
}
}

output amlWorkspaceId string = amlFnolWspace.id
output amlWorkspaceNameOut string = amlFnolWspace.name
output pilotUploadsDatastoreId string = pilotUploadsDatastore.id
output mlComputeId string = mlCompute.id

