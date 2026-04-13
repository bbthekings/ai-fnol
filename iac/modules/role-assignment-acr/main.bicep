targetScope = 'resourceGroup'

param aksPrincipalId string
param acrName string

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource aksToAcrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrResource.id, aksPrincipalId, 'AcrPull')
  scope: acrResource
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-435727c5752a'
    principalId: aksPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output aksToAcrRoleId string = aksToAcrRole.id
