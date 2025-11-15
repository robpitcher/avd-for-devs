// Role Assignment Module
// Assigns an Entra ID principal to an application group

@description('The application group resource ID')
param appGroupId string

@description('The Entra ID principal (user or group) Object ID')
param principalId string

@description('The principal type')
@allowed(['User', 'Group', 'ServicePrincipal'])
param principalType string = 'Group'

// Desktop Virtualization User role ID
var desktopVirtualizationUserRoleId = '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63'

// Get the application group resource
resource appGroup 'Microsoft.DesktopVirtualization/applicationGroups@2023-09-05' existing = {
  name: last(split(appGroupId, '/'))
}

// Role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appGroupId, principalId, desktopVirtualizationUserRoleId)
  scope: appGroup
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', desktopVirtualizationUserRoleId)
    principalId: principalId
    principalType: principalType
  }
}

@description('The role assignment resource ID')
output roleAssignmentId string = roleAssignment.id
