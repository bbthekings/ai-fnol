
param vnetName string
param location string

resource nsgAks 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: 'nsg-aks'
  location: location

  //properties:{
  //   securityRules: [ ] // Rules would go here, but Azure provides defaults
  // }
}


resource vnetFnolPilot 'Microsoft.Network/virtualNetworks@2024-03-01' = {
		  name: vnetName  
		  location: location
      properties: {
        addressSpace: {
          addressPrefixes: ['10.0.0.0/16'] // The total range of IPs available
                                           // /16: the first two numbers (10.0) are locked. 
                                           // If we only lock the first number (10.x.x.x/8),the VNet would claim 16.7 million IP addresses.
                                           // -> The Conflict: if we ever want to connect this VNet to another one (Peering) 
                                           // or to office on-premise network via VPN, they cannot have overlapping 
                                           // addresses (like a computer in vnet_1 trying to send a msg to vnet_2.<191.23.4.5> but ends 
                                           // sending it to vnet_1.<191.23.4.5> due to overlapping.)
                                           // -> The Strategy: By locking 10.0.x.x, you leave 10.1.x.x, 10.2.x.x, etc., 
                                           // open for other pilots, other departments, or corporate office, it allows for 
                                           // "neighbors" without collisions.
                                           // 2^(16) = 65.536 possible ips
        }
        subnets: [
          {
            name: 'snet-app'
            properties: {
             addressPrefix: '10.0.1.0/24' // /24: the first 3 numbers (10.0.1) are locked.
                                          // 2^(8) = 256 possible ips
            }
          } 
          {
            name: 'snet-aks'
            properties: {
             addressPrefix: '10.0.2.0/24' // /24: the first 3 numbers (10.0.2) are locked.
                                          // 2^(8) = 256 possible ips
            networkSecurityGroup: { id: nsgAks.id   } // refer to NSG
            }
          }
        ]
      
      }
		}

    output vnetFnolPilotId string = vnetFnolPilot.id
    output snetAppId string = vnetFnolPilot.properties.subnets[0].id
    output snetAksId string = vnetFnolPilot.properties.subnets[1].id
    output nsgAksId string = nsgAks.id
