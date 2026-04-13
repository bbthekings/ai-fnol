
param kvFnolPilotName string = 'kv-fnol-pilot'
param location string = 'germanywestcentral' // default region

resource kvFnolPilot 'Microsoft.KeyVault/vaults@2024-11-01' = {
  
 location: location
 name: kvFnolPilotName

 properties: {
  tenantId: subscription().tenantId
  enableRbacAuthorization: true // enable rbac (disables legacy Access Policies)
  enablePurgeProtection: false // for a pilot: the vault can still be deleted cleanly during destroy tests.
  enableSoftDelete: true        // Allows recovery of deleted items

  sku:  {
    family : 'A' // shared service
    name: 'standard' // not premium
  }
 }
}

output keyVaultId string = kvFnolPilot.id
output keyVaultName string = kvFnolPilot.name
