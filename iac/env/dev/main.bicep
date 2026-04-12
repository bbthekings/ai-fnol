
targetScope = 'subscription' // High-level starting point

param rgname string = 'rg-fnol-pilot-dev'
param location string = 'germanywestcentral'
param vnetName string = 'vnet-fnol-pilot'
param stFnolPilotName string = 'storagefnolpilot'

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

