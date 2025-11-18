// Workspace Module
// AVD Workspace for organizing application groups

@description('The name of the workspace')
param workspaceName string

@description('The location for the workspace')
param location string

@description('Friendly name for the workspace')
param friendlyName string = 'AVD Development Workspace'

@description('Description of the workspace')
param workspaceDescription string = 'Workspace for AVD development environment'

@description('Tags to apply to resources')
param tags object = {}

// Workspace
resource workspace 'Microsoft.DesktopVirtualization/workspaces@2023-09-05' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    friendlyName: friendlyName
    description: workspaceDescription
  }
}

@description('The resource ID of the workspace')
output workspaceId string = workspace.id

@description('The name of the workspace')
output workspaceName string = workspace.name
