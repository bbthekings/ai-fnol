targetScope='subscription'

param location string
param resourceGroupName  string

resource rgFnolPilot 'Microsoft.Resources/resourceGroups@2024-03-01' = {
		  name: resourceGroupName  
		  location: location
		}

output rgId string = rgFnolPilot.id
output resourceGroupName string = rgFnolPilot.name

