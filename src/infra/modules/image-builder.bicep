// Image Builder Module
// Azure Image Builder template for custom Windows 11 image with VS Code

@description('The location for image builder resources')
param location string

@description('The name prefix for the image')
param imageNamePrefix string = 'devavd'

@description('Base image publisher')
param baseImagePublisher string = 'MicrosoftWindowsDesktop'

@description('Base image offer')
param baseImageOffer string = 'Windows-11'

@description('Base image SKU')
param baseImageSku string = 'win11-22h2-ent-multi-session'

@description('Winget package ID for VS Code')
param vscodeWingetId string = 'Microsoft.VisualStudioCode'

@description('Resource group for managed image output')
param imageResourceGroup string

@description('Current UTC time for timestamp generation')
param currentTime string = utcNow()

@description('Tags to apply to resources')
param tags object = {}

// Generate unique image name with timestamp
var timestamp = replace(replace(replace(currentTime, '-', ''), ':', ''), 'T', '')
var imageName = '${imageNamePrefix}-${substring(timestamp, 0, 12)}'

// Placeholder for Image Builder Template
// Note: Full implementation requires managed identity, staging resource group, etc.
// This is a simplified structure - actual deployment may need additional setup

@description('The name of the generated image')
output imageName string = imageName

@description('The expected image resource ID')
output imageId string = resourceId(imageResourceGroup, 'Microsoft.Compute/images', imageName)
