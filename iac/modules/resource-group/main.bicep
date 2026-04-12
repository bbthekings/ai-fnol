targetScope='subscription'

param location string = 'germanywestcentral' // default region
param resourceGroupName  string = 'rg-fnol-pilot-dev' // default region

resource rgFnolPilot 'Microsoft.Resources/resourceGroups@2024-03-01' = {
		  name: resourceGroupName  
		  location: location
		}

output rgId string = rgFnolPilot.id

