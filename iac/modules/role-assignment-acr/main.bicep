

param aksPrincipalId string
param acrFnolPilotName string


resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrFnolPilotName
}

 // Entra ID provides the ID Badge (Identity). 
 // This code tells the Security Guard at the ACR Building (Role Assignment)
 // to let anyone with that specific badge inside.

// role=keycard for AKS to access ACR
resource aksToAcrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  
  // Use a deterministic name so redeployments don't create duplicates
  name: guid(acrResource.id, aksPrincipalId, 'AcrPull') // The "AcrPull" definition is a global badge template in Azure.
  scope: acrResource
  properties: {
    // The official Azure ID for the 'AcrPull' Role
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '7f951dda-4ed3-4680-a7ca-435727c5752a'
    )
    // The "Badge Number" of the Master Server
    principalId: aksPrincipalId
    // CRITICAL: Always specify principalType to avoid intermittent deployment delays
    principalType: 'ServicePrincipal' 
  }
}

output aksToAcrRoleName string = aksToAcrRole.name
output aksToAcrRoleId string = aksToAcrRole.id

