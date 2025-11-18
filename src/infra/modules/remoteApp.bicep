// RemoteApp Module
// Publishes an application in the application group

@description('The name of the RemoteApp')
param remoteAppName string

@description('The display name for the RemoteApp')
param displayName string

@description('The command path for the application')
param commandPath string

@description('The application group name where this app will be published')
param appGroupName string

@description('Description of the RemoteApp')
param appDescription string = 'RemoteApp published via Azure Virtual Desktop'

@description('Command line arguments (optional)')
param commandLineArguments string = ''

@description('Show in portal')
param showInPortal bool = true

// RemoteApp resource
resource remoteApp 'Microsoft.DesktopVirtualization/applicationGroups/applications@2023-09-05' = {
  name: '${appGroupName}/${remoteAppName}'
  properties: {
#disable-next-line BCP334
    description: appDescription
    friendlyName: displayName
    filePath: commandPath
    commandLineSetting: 'DoNotAllow'
    commandLineArguments: commandLineArguments
    showInPortal: showInPortal
    applicationType: 'InBuilt'
  }
}

@description('The resource ID of the RemoteApp')
output remoteAppId string = remoteApp.id

@description('The name of the RemoteApp')
output remoteAppName string = remoteApp.name
