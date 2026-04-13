
targetScope = 'subscription' // High-level starting point

param rgname string 
param location string 
//
param vnetName string 
//
param stFnolPilotName string 
//
param kvFnolPilotName string 
//
param amlWorkspaceName string 
//
param logAnalyticsName string 
param applInsightsName string 
//
param acrName string 
//
param aksFnolPilotName string 
//
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
		  name: 'acrDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        acrName: acrName
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// call aks
module aksModule '../../modules/aks/main.bicep' = {
		  name: 'aksDeployment'
      scope: resourceGroup(rgname) 
		  params: { 
        location: location 
        aksFnolPilotName:  aksFnolPilotName
		  }
      dependsOn: [
        resourceGroupModule
      ]
}

// this is added as workflow step after azure/arm-deploy@v2 (gh action)
// call aks --access role--> acr
/* module aksToAcrRoleModule '../../modules/role-assignment-acr/main.bicep' = {
  name: 'aksToAcrRoleDeployment'
  scope: resourceGroup(rgname)
  params: {
    aksPrincipalId: aksModule.outputs.aksIdentityId
    acrName: acrModule.outputs.acrName
  }
  dependsOn: [
    resourceGroupModule
  ]
} */

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




 
    