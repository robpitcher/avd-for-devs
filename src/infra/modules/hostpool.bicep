// Host Pool Module
// AVD Host Pool with configurable load balancing and session limits

@description('The name of the host pool')
param hostPoolName string

@description('The location for the host pool')
param location string

@description('Friendly name for the host pool')
param friendlyName string = 'AVD Development Host Pool'

@description('Load balancing strategy')
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param loadBalancingStrategy string = 'BreadthFirst'

@description('Maximum sessions per host')
@minValue(1)
param maxSessionsPerHost int = 10

@description('Host pool type')
param hostPoolType string = 'Pooled'

@description('Preferred app group type')
param preferredAppGroupType string = 'RailApplications'

@description('Registration token expiration in hours')
@minValue(1)
param registrationTokenExpirationHours int = 24

@description('Current UTC time for token expiration calculation')
param currentTime string = utcNow()

@description('Tags to apply to resources')
param tags object = {}

// Calculate token expiration time
var tokenExpirationTime = dateTimeAdd(currentTime, 'PT${registrationTokenExpirationHours}H')

// Host Pool
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2023-09-05' = {
  name: hostPoolName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancingStrategy
    maxSessionLimit: maxSessionsPerHost
    preferredAppGroupType: preferredAppGroupType
    registrationInfo: {
      expirationTime: tokenExpirationTime
      registrationTokenOperation: 'Update'
    }
  }
}

@description('The resource ID of the host pool')
output hostPoolId string = hostPool.id

@description('The name of the host pool')
output hostPoolName string = hostPool.name

@description('The registration token for joining session hosts')
output registrationToken string = hostPool.properties.registrationInfo.token

@description('The token expiration time')
output tokenExpirationTime string = tokenExpirationTime
