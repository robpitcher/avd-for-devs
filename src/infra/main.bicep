targetScope = 'subscription'

param location string

// Create resource group
resource rgAvd 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-avd'
  location: location
}

// Create VNET using Azure verified module
