# Quickstart: Azure Virtual Desktop Dev Environment (VS Code RemoteApp)

## Overview
Deploy a low-cost AVD environment with a custom Windows 11 multi-session image (VS Code pre-installed) and a single published RemoteApp.

## Prerequisites
- Azure subscription with Contributor rights at subscription scope
- Az PowerShell module or Azure CLI installed
- Entra ID security group created for developer access (capture its Object ID)
- Logged in: `Connect-AzAccount` (PowerShell) or `az login`

## Parameter Preparation
Create a parameter file (example: `dev.bicepparam`) reflecting schema in `contracts/parameters.schema.json`:
```bicep
using './src/infra/main.bicep'
param location = 'canadacentral'
param hostPoolName = 'dev-avd-hostpool'
param loadBalancingStrategy = 'BreadthFirst'
param maxSessionsPerHost = 10
param hostCount = 1
param vmSize = 'Standard_D2s_v5'
param adminUsername = 'avdadmin'
// Secure input at deploy time
param adminPassword = 'CHANGE_ME_SECURELY'
param baseImagePublisher = 'MicrosoftWindowsDesktop'
param baseImageOffer = 'Windows-11'
param baseImageSku = 'win11-22h2-ent-multi-session'
param imageBuilderEnabled = true
param vscodeWingetId = 'Microsoft.VisualStudioCode'
param imageNamePrefix = 'devavd'
param workspaceName = 'dev-avd-ws'
param appGroupName = 'dev-avd-appgrp'
param remoteAppDisplayName = 'Visual Studio Code'
param remoteAppCommandPath = 'C\\Program Files\\Microsoft VS Code\\Code.exe'
param entraIdGroupObjectId = '<YOUR_GROUP_OBJECT_ID>'
param vnetName = 'dev-avd-vnet'
param vnetAddressPrefixes = [ '10.20.0.0/16' ]
param subnetName = 'dev-avd-subnet'
param subnetAddressPrefix = '10.20.1.0/24'
param registrationTokenExpirationHours = 24
```

## Image Build (If Enabled)
If `imageBuilderEnabled = true`, deployment will:
1. Create Image Builder template referencing marketplace base image.
2. Run customization (winget install VS Code).
3. Produce managed image tagged with timestamp.

## Deployment
### What-If (Optional Validation)
```powershell
New-AzSubscriptionDeployment -Location canadacentral -Name avd-whatif -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\dev.bicepparam -WhatIf
```

### Actual Deploy
```powershell
New-AzSubscriptionDeployment -Location canadacentral -Name avd-deploy -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\dev.bicepparam
```
Capture outputs (registration token, image ID if built) from command result.

## Assign Access
Assign Entra ID group to Application Group resource (if not handled automatically) or verify assignment was deployed.

## Test RemoteApp
1. User in group opens AVD client or web portal.
2. Locates "Visual Studio Code" RemoteApp.
3. Launches; confirm session within ≤ 60 seconds.

## Scaling Hosts
Update `hostCount` in parameter file (e.g., from 1 to 2) and redeploy.
```powershell
New-AzSubscriptionDeployment -Location canadacentral -Name avd-scale -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\dev.bicepparam
```
Confirm new host registers in Host Pool.

## Updating Image
1. Set `imageBuilderEnabled = true` (if previously false) and adjust base image SKU if newer.
2. Redeploy; new managed image created.
3. Incrementally replace hosts (reduce `hostCount` after draining old host, then redeploy).

## Cleanup
```powershell
Remove-AzResourceGroup -Name <resourceGroupIfUsed> -Force
```
Or delete created resources individually if deployed at subscription scope without dedicated RG (recommend using a resource group).

## Troubleshooting
- RemoteApp missing: Verify Entra ID group Object ID.
- VS Code path invalid: Check image customization logs and adjust `remoteAppCommandPath`.
- Capacity errors: Increase `hostCount` or `maxSessionsPerHost`.

## Future Enhancements
- Automated CI what-if validation
- Log Analytics integration
- Additional dev tools baked into image
