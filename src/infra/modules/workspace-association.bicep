// Workspace Association Module
// Associates application groups with the workspace

@description('The name of the workspace')
param workspaceName string

@description('The location of the workspace')
param location string

@description('The friendly name of the workspace')
param friendlyName string = 'AVD Development Workspace'

@description('The description of the workspace')
param workspaceDescription string = 'Workspace for AVD development environment'

@description('Array of application group resource IDs to associate')
param applicationGroupIds array

@description('Tags to apply to resources')
param tags object = {}

// Update workspace with application group references
resource workspaceUpdate 'Microsoft.DesktopVirtualization/workspaces@2023-09-05' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    applicationGroupReferences: applicationGroupIds
    friendlyName: friendlyName
    description: workspaceDescription
  }
}

@description('Updated workspace resource ID')
output workspaceId string = workspaceUpdate.id
