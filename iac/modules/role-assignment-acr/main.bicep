
targetScope = 'resourceGroup'

param aksPrincipalId string
param acrName string

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-435727c5752a'
}

resource aksToAcrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrResource.id, aksPrincipalId, acrPullRole.id)
  scope: acrResource
  properties: {
    roleDefinitionId: acrPullRole.id
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output aksToAcrRoleId string = aksToAcrRole.id
