
param acrFnolPilotName string
param acrFnolPilotNameUnique string = '${acrFnolPilotName}${uniqueString(subscription().id, resourceGroup().name)}'

param location string = 'germanywestcentral' // default region

resource acrFnolPilot 'Microsoft.ContainerRegistry/registries@2023-07-01' = {

   name: acrFnolPilotNameUnique
   location: location

   sku: {
    name: 'Basic' // Mandatory for ACR
  }

  properties: {
    adminUserEnabled: true // Often required for AML to authenticate easily
    publicNetworkAccess: 'Enabled'
  }

}

output acrFnolPilotId string = acrFnolPilot.id
output acrFnolPilotName string = acrFnolPilot.name



