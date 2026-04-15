
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
  name: 'ds-pilot-uploads'
  properties: {
    description: 'Datastore for FNOL pilot upload parquet files'
    datastoreType: 'AzureBlob'
    accountName: storageAccountName
    containerName: 'pilot-uploads'
    endpoint: 'core.windows.net'
    protocol: 'https'
    serviceDataAccessAuthIdentity: 'WorkspaceSystemAssignedIdentity'
    credentials: {
      credentialsType: 'None'
    }
  }
}

// storage resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Grant the 'AML Workspace Identity' access to the Storage Account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, 'StorageBlobDataContributor', amlFnolWspace.id)
  scope: storageAccount // The storage account resource
  properties: {
    // Storage Blob Data Contributor ID
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') 
    principalId: amlFnolWspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output amlWorkspaceId string = amlFnolWspace.id
output amlWorkspaceNameOut string = amlFnolWspace.name
output pilotUploadsDatastoreId string = pilotUploadsDatastore.id
output storageRoleAssignmentId string = storageRoleAssignment.id

