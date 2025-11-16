using 'main.bicep'

// Location
param location = 'canadacentral'

// Host Pool Configuration
param hostPoolName = 'dev-avd-hostpool'
param loadBalancingStrategy = 'BreadthFirst'
param maxSessionsPerHost = 10

// Session Host Configuration
param hostCount = 1
param vmSize = 'Standard_D2s_v5'
param adminUsername = 'avdadmin'
// IMPORTANT: Set adminPassword at deployment time using --parameters or secure input
// Example: --parameters adminPassword='<SecurePassword>'
param adminPassword = '' // Must be provided at deployment

// Base Image Configuration
param baseImagePublisher = 'MicrosoftWindowsDesktop'
param baseImageOffer = 'Windows-11'
param baseImageSku = 'win11-22h2-ent-multi-session'

// Custom Image Builder Configuration
param imageBuilderEnabled = true
param vscodeWingetId = 'Microsoft.VisualStudioCode'
param imageNamePrefix = 'devavd'

// Workspace and Application Group
param workspaceName = 'dev-avd-ws'
param appGroupName = 'dev-avd-appgrp'
param remoteAppDisplayName = 'Visual Studio Code'
param remoteAppCommandPath = 'C:\\Program Files\\Microsoft VS Code\\Code.exe'

// Access Control
// IMPORTANT: Replace with your Entra ID security group Object ID
// To find: Azure Portal > Entra ID > Groups > [Your Group] > Object ID
param entraIdGroupObjectId = '00000000-0000-0000-0000-000000000000'

// Network Configuration
param vnetName = 'dev-avd-vnet'
param vnetAddressPrefixes = ['10.20.0.0/16']
param subnetName = 'dev-avd-subnet'
param subnetAddressPrefix = '10.20.1.0/24'

// Registration Token
param registrationTokenExpirationHours = 24
