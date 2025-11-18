// Network Module - Virtual Network and Subnet
// Uses Azure Verified Modules pattern

@description('The name of the virtual network')
param vnetName string

@description('The location for the virtual network')
param location string

@description('The address prefixes for the virtual network')
param vnetAddressPrefixes array = ['10.20.0.0/16']

@description('The name of the subnet')
param subnetName string

@description('The address prefix for the subnet')
param subnetAddressPrefix string

@description('Tags to apply to resources')
param tags object = {}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

@description('The resource ID of the virtual network')
output vnetId string = vnet.id

@description('The resource ID of the subnet')
output subnetId string = vnet.properties.subnets[0].id

@description('The name of the subnet')
output subnetName string = subnetName
