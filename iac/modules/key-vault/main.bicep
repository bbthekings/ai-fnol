
param kvFnolPilotName string
param location string

// uniqueString() generates 13 chars, leaving 11 for your prefix.
var kvFnolPilotNameUnique = '${kvFnolPilotName}${uniqueString(resourceGroup().id)}' 

resource kvFnolPilot 'Microsoft.KeyVault/vaults@2024-11-01' = {
  
 location: location
 name: kvFnolPilotNameUnique

 properties: {
  tenantId: subscription().tenantId
  enableRbacAuthorization: true // enable rbac (disables legacy Access Policies)
  enableSoftDelete: true        // Allows recovery of deleted items
  accessPolicies: [] // mandatory for creation 
  publicNetworkAccess: 'Enabled' // we can harden later

  sku:  {
    family : 'A' // shared service
    name: 'standard' // not premium
  }
 }
}

output keyVaultId string = kvFnolPilot.id
output keyVaultName string = kvFnolPilot.name
