
targetScope = 'subscription' // High-level starting point

param rgname string = 'rg-fnol-pilot-dev'
param location string = 'germanywestcentral'
param vnetName string = 'vnet-fnol-pilot'
param stFnolPilotName string = 'storagefnolpilot'
param kvFnolPilotName string = 'kv-fnol'
param amlWorkspaceName string = 'aml-wspace-fnol'

var kvFnolPilotNameUnique string = take('${kvFnolPilotName}-${uniqueString(subscription().id, rgname)}', 24)

// call resource-group
module resourceGroupModule '../../modules/resource-group/main.bicep' = {
		  name: 'resourceGroupDeployment'
		  params: { 
        location: location 
        resourceGroupName: rgname
		  }
}

// call network
module networkModule '../../modules/network/main.bicep' = {
		  name: 'networkDeployment'
      scope: resourceGroup(rgname)
		  params: { 
        location: location 
        vnetName: vnetName
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// call storage
module storageModule '../../modules/storage/main.bicep' = {
		  name: 'storageDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        stFnolPilotName:  stFnolPilotName
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// call keyvault
module keyvaultModule '../../modules/key-vault/main.bicep' = {
		  name: 'keyvaultDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        kvFnolPilotName:  kvFnolPilotNameUnique
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// call aml
module amlWorkspaceModule '../../modules/aml-workspace/main.bicep' = {
		  name: 'amlWorkspaceDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        amlWorkspaceName:  amlWorkspaceName
        storageAccountId: storageModule.outputs.storageAccountId 
        keyVaultId: keyvaultModule.outputs.keyVaultId
        // appInsightsId: appInsightsModule.outputs.id 
        // containerRegistryId: acrModule.outputs.id
		  }
      dependsOn: [
        resourceGroupModule
      ]
}
    
 
    