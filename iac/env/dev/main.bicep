
targetScope = 'subscription' // High-level starting point

param rgname string = 'rg-fnol-pilot-dev'
param location string = 'germanywestcentral'
//
param vnetName string = 'vnet-fnol-pilot'
//
param stFnolPilotName string = 'storagefnolpilot'
//
param kvFnolPilotName string = 'kv-fnol'
//
param amlWorkspaceName string = 'aml-wspace-fnol'
//
param logAnalyticsName string = 'log-analytics-fnol'
param applInsightsName string = 'appl-insights-fnol'
//
param acrFnolPilotName string = 'acr-fnol-pilot'

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

// call appl-insights
module applInsightsModule '../../modules/appl-insights/main.bicep' = {
		  name: 'applInsightsDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        logAnalyticsName: logAnalyticsName
        applInsightsName: applInsightsName
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// call acr
module acrModule '../../modules/acr/main.bicep' = {
		  name: 'amlWorkspaceDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        acrFnolPilotName:  acrFnolPilotName
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
        applInsightsId: applInsightsModule.outputs.applInsightsId 
        containerRegistryId: acrModule.outputs.acrFnolPilotId
		  }
      dependsOn: [
        resourceGroupModule
      ]
}


 
    