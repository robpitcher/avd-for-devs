targetScope = 'subscription'

// Location parameter
@description('Azure region for resources')
param location string

// Host Pool Configuration
@description('The name of the host pool')
param hostPoolName string

@description('Load balancing strategy')
@allowed(['BreadthFirst', 'DepthFirst'])
param loadBalancingStrategy string = 'BreadthFirst'

@description('Maximum sessions per host')
@minValue(1)
param maxSessionsPerHost int = 10

// Session Host Configuration
@description('Number of session host VMs to create')
@minValue(1)
param hostCount int = 1

@description('VM size for session hosts')
param vmSize string = 'Standard_D2s_v5'

@description('Admin username for session hosts')
param adminUsername string

@description('Admin password for session hosts')
@secure()
param adminPassword string

// Base Image Configuration
@description('Base image publisher')
param baseImagePublisher string = 'MicrosoftWindowsDesktop'

@description('Base image offer')
param baseImageOffer string = 'Windows-11'

@description('Base image SKU')
param baseImageSku string = 'win11-22h2-ent-multi-session'

// Custom Image Builder Configuration
@description('Enable custom image builder')
param imageBuilderEnabled bool = true

@description('Winget package ID for VS Code')
param vscodeWingetId string = 'Microsoft.VisualStudioCode'

@description('Prefix for custom image names')
param imageNamePrefix string = 'devavd'

// Workspace and Application Group
@description('Name of the AVD workspace')
param workspaceName string

@description('Name of the application group')
param appGroupName string

@description('Display name for the RemoteApp')
param remoteAppDisplayName string = 'Visual Studio Code'

@description('Command path for the RemoteApp')
param remoteAppCommandPath string = 'C:\\Program Files\\Microsoft VS Code\\Code.exe'

// Access Control
@description('Entra ID group Object ID for access assignment')
param entraIdGroupObjectId string

// Network Configuration
@description('Virtual network name')
param vnetName string

@description('Virtual network address prefixes')
param vnetAddressPrefixes array = ['10.20.0.0/16']

@description('Subnet name')
param subnetName string

@description('Subnet address prefix')
param subnetAddressPrefix string

// Registration Token
@description('Registration token expiration in hours')
@minValue(1)
param registrationTokenExpirationHours int = 24

// Common tags
var commonTags = {
  environment: 'dev'
  feature: 'avd-vscode'
  managedBy: 'bicep'
}

// Resource group name
var resourceGroupName = 'rg-avd-dev'

// Create resource group
resource rgAvd 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

// Deploy network module
module network 'modules/network.bicep' = {
  scope: rgAvd
  name: 'deploy-network'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
    tags: commonTags
  }
}

// Deploy host pool module
module hostPool 'modules/hostpool.bicep' = {
  scope: rgAvd
  name: 'deploy-hostpool'
  params: {
    location: location
    hostPoolName: hostPoolName
    loadBalancingStrategy: loadBalancingStrategy
    maxSessionsPerHost: maxSessionsPerHost
    registrationTokenExpirationHours: registrationTokenExpirationHours
    tags: commonTags
  }
}

// Deploy workspace module
module workspace 'modules/workspace.bicep' = {
  scope: rgAvd
  name: 'deploy-workspace'
  params: {
    location: location
    workspaceName: workspaceName
    tags: commonTags
  }
}

// Deploy application group module
module appGroup 'modules/appGroup.bicep' = {
  scope: rgAvd
  name: 'deploy-appgroup'
  params: {
    location: location
    appGroupName: appGroupName
    hostPoolId: hostPool.outputs.hostPoolId
    tags: commonTags
  }
}

// Associate application group with workspace
module workspaceAssociation 'modules/workspace-association.bicep' = {
  scope: rgAvd
  name: 'deploy-workspace-association'
  params: {
    location: location
    workspaceName: workspaceName
    applicationGroupIds: [appGroup.outputs.appGroupId]
    tags: commonTags
  }
}

// Publish VS Code RemoteApp
module vscodeRemoteApp 'modules/remoteApp.bicep' = {
  scope: rgAvd
  name: 'deploy-vscode-remoteapp'
  params: {
    remoteAppName: 'VSCode'
    displayName: remoteAppDisplayName
    commandPath: remoteAppCommandPath
    appGroupName: appGroupName
    appDescription: 'Visual Studio Code development environment'
  }
}

// Assign Entra ID group to application group
module appGroupRoleAssignment 'modules/role-assignment.bicep' = {
  scope: rgAvd
  name: 'deploy-appgroup-assignment'
  params: {
    appGroupId: appGroup.outputs.appGroupId
    principalId: entraIdGroupObjectId
    principalType: 'Group'
  }
}

// Image reference (marketplace or custom)
var useCustomImage = imageBuilderEnabled
var imageReference = useCustomImage ? {
  id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Compute/images/${imageNamePrefix}-placeholder'
} : {
  publisher: baseImagePublisher
  offer: baseImageOffer
  sku: baseImageSku
  version: 'latest'
}

// Deploy custom image builder (if enabled)
module imageBuilder 'modules/image-builder.bicep' = if (imageBuilderEnabled) {
  scope: rgAvd
  name: 'deploy-imagebuilder'
  params: {
    location: location
    imageNamePrefix: imageNamePrefix
    baseImagePublisher: baseImagePublisher
    baseImageOffer: baseImageOffer
    baseImageSku: baseImageSku
    vscodeWingetId: vscodeWingetId
    imageResourceGroup: resourceGroupName
    tags: commonTags
  }
}

// Deploy session host VMs
module sessionHosts 'modules/sessionHostVM.bicep' = [for i in range(0, hostCount): {
  scope: rgAvd
  name: 'deploy-sessionhost-${i}'
  params: {
    location: location
    vmNamePrefix: 'avd-vm'
    vmIndex: i
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: network.outputs.subnetId
    hostPoolToken: hostPool.outputs.registrationToken
    imageReference: imageReference
    tags: commonTags
  }
}]

// Outputs
@description('Host pool resource ID')
output hostPoolId string = hostPool.outputs.hostPoolId

@description('Workspace resource ID')
output workspaceId string = workspace.outputs.workspaceId

@description('Application group resource ID')
output appGroupId string = appGroup.outputs.appGroupId

@description('Registration token (sensitive)')
output registrationToken string = hostPool.outputs.registrationToken

@description('Custom image name (if enabled)')
output customImageName string = imageBuilderEnabled ? '${imageNamePrefix}-timestamp' : 'marketplace'

@description('Session host VM names')
output sessionHostNames array = [for i in range(0, hostCount): sessionHosts[i].outputs.vmName]
