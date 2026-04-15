
param aksFnolPilotName string
param location string

resource aksFnolPilot 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
 name: aksFnolPilotName
 location: location

 identity: {
    type: 'SystemAssigned' // Automates security/authentication
  }
 properties: {
 dnsPrefix: '${aksFnolPilotName}-dns' // for creating  the unique URL for the master Server
  // worker modes
 agentPoolProfiles: [
      {
        name: 'systempool'
        count: 2           // "Slave" servers = Worker Nodes
        vmSize: 'Standard_DS2_v2'
        mode: 'System'     // Mandatory for the first pool
        osType: 'Linux'
      }
    ]
  }

}

// Output the master-server identity ID so you can grant it access to ACR later
output aksIdentityId string = aksFnolPilot.identity.principalId
output aksName string = aksFnolPilot.name
