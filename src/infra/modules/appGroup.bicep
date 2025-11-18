// Application Group Module
// AVD Application Group for RemoteApp publishing

@description('The name of the application group')
param appGroupName string

@description('The location for the application group')
param location string

@description('The resource ID of the host pool')
param hostPoolId string

@description('Friendly name for the application group')
param friendlyName string = 'AVD Development Apps'

@description('Description of the application group')
param appGroupDescription string = 'Application group for development tools'

@description('Application group type')
@allowed([
  'RemoteApp'
  'Desktop'
])
param applicationGroupType string = 'RemoteApp'

@description('Tags to apply to resources')
param tags object = {}

// Application Group
resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2023-09-05' = {
  name: appGroupName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    description: appGroupDescription
    applicationGroupType: applicationGroupType
    hostPoolArmPath: hostPoolId
  }
}

@description('The resource ID of the application group')
output appGroupId string = appGroup.id

@description('The name of the application group')
output appGroupName string = appGroup.name
