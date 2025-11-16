# Quickstart: Azure Virtual Desktop Dev Environment (VS Code RemoteApp)

## Overview
Deploy a low-cost AVD environment using Windows 11 multi-session marketplace image with automated VS Code installation via custom script extension and a single published RemoteApp.

**Key Features:**
- No custom image build required - uses marketplace images
- VS Code installed automatically during VM provisioning
- Fast deployment (~10-15 minutes)
- Simple parameter-driven scaling

## Prerequisites
- Azure subscription with Contributor rights at subscription scope
- Azure CLI installed (`az --version`)
- Entra ID security group created for developer access (capture its Object ID)
- Logged in: `az login`

## Parameter Preparation
Create or edit a parameter file based on `src/infra/parameters/example.bicepparam`:

```bicep
using '../main.bicep'

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
param adminPassword = '' // Provide at deployment time

// Base Image Configuration (marketplace)
param baseImagePublisher = 'MicrosoftWindowsDesktop'
param baseImageOffer = 'Windows-11'
param baseImageSku = 'win11-22h2-ent-multi-session'

// VS Code Installation Script
param vscodeInstallScriptUri = 'https://raw.githubusercontent.com/robpitcher/avd-for-devs/main/src/infra/scripts/install-vscode.ps1'

// Workspace and Application Group
param workspaceName = 'dev-avd-ws'
param appGroupName = 'dev-avd-appgrp'
param remoteAppDisplayName = 'Visual Studio Code'
param remoteAppCommandPath = 'C:\\Program Files\\Microsoft VS Code\\Code.exe'

// Access Control - REPLACE WITH YOUR GROUP OBJECT ID
param entraIdGroupObjectId = '00000000-0000-0000-0000-000000000000'

// Network Configuration
param vnetName = 'dev-avd-vnet'
param vnetAddressPrefixes = ['10.20.0.0/16']
param subnetName = 'dev-avd-subnet'
param subnetAddressPrefix = '10.20.1.0/24'

// Registration Token
param registrationTokenExpirationHours = 24
```

## Deployment

### What-If Validation (Recommended)
Preview changes before actual deployment:
```bash
az deployment sub what-if \
  --location canadacentral \
  --template-file ./src/infra/main.bicep \
  --parameters ./src/infra/parameters/dev.bicepparam \
  --parameters adminPassword='<YourSecurePassword>'
```

### Deploy Infrastructure
```bash
az deployment sub create \
  --location canadacentral \
  --name avd-deploy-$(date +%Y%m%d-%H%M%S) \
  --template-file ./src/infra/main.bicep \
  --parameters ./src/infra/parameters/dev.bicepparam \
  --parameters adminPassword='<YourSecurePassword>'
```

**Expected Duration:** 10-15 minutes

**Deployment Steps:**
1. Creates resource group `rg-avd-dev`
2. Deploys VNet and subnet
3. Creates host pool with registration token
4. Creates workspace and application group
5. Associates app group with workspace
6. Publishes VS Code RemoteApp
7. Assigns Entra ID group to app group
8. Provisions session host VMs from marketplace image
9. Executes custom script extension to install VS Code

### Monitor Deployment
View deployment progress:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.provisioningState
```

View custom script extension status:
```bash
az vm extension list \
  --resource-group rg-avd-dev \
  --vm-name avd-vm-000 \
  --output table
```

### Capture Outputs
After successful deployment:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs
```

Outputs include:
- `hostPoolId`: Resource ID of host pool
- `workspaceId`: Resource ID of workspace
- `appGroupId`: Resource ID of application group
- `registrationToken`: Token for manual host additions (valid 24h)
- `sessionHostNames`: Array of deployed VM names

## Verify Access
Access is automatically assigned during deployment. Verify:
```bash
az role assignment list \
  --scope $(az desktopvirtualization applicationgroup show \
    --resource-group rg-avd-dev \
    --name dev-avd-appgrp \
    --query id -o tsv) \
  --output table
```

## Test RemoteApp
1. User in assigned Entra ID group opens:
   - **Windows AVD Client**: Download from Microsoft Store or web
   - **Web Portal**: https://client.wvd.microsoft.com/arm/webclient
2. Signs in with Entra ID credentials
3. Locates "Visual Studio Code" RemoteApp
4. Launches application
5. **Expected Result**: VS Code session launches within ≤ 60 seconds

## Scaling Session Hosts
Increase capacity by updating `hostCount` parameter:

```bash
# Edit parameter file, change hostCount from 1 to 2
az deployment sub create \
  --location canadacentral \
  --name avd-scale-$(date +%Y%m%d-%H%M%S) \
  --template-file ./src/infra/main.bicep \
  --parameters ./src/infra/parameters/dev.bicepparam \
  --parameters adminPassword='<YourSecurePassword>' \
  --parameters hostCount=2
```

**Expected Duration:** ~10 minutes for each additional host

New hosts automatically:
- Provision from marketplace image
- Install VS Code via script extension
- Register to host pool
- Accept user sessions

## Scaling Down
See `docs/scaling-down.md` for procedure to safely remove hosts after draining sessions.

## Updating Installation Script
Update VS Code installation or add additional tools:

1. Edit `src/infra/scripts/install-vscode.ps1`
2. If hosted externally, update `vscodeInstallScriptUri` parameter
3. Deploy new session hosts (increase `hostCount` or replace existing)
4. New hosts use updated script automatically

**Note:** Existing session hosts are not automatically updated. Replace by scaling down old hosts and scaling up new ones.

## Troubleshooting

### RemoteApp Not Visible
- Verify user is member of assigned Entra ID group
- Check group Object ID matches `entraIdGroupObjectId` parameter
- Allow 5-10 minutes for group membership propagation

### VS Code Installation Failed
Check custom script extension logs:
```bash
az vm extension show \
  --resource-group rg-avd-dev \
  --vm-name avd-vm-000 \
  --name CustomScriptExtension \
  --query instanceView.statuses
```

View detailed logs (requires VM access):
- Windows Event Viewer: Applications and Services Logs > Microsoft > Windows > Apps > CustomScript
- `C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension`

### Session Host Not Registered
Verify AVD agent installation:
```bash
# Check VM extension status
az vm extension list \
  --resource-group rg-avd-dev \
  --vm-name avd-vm-000 \
  --output table
```

### Capacity Errors
- Increase `maxSessionsPerHost` for more concurrent sessions per host
- Increase `hostCount` to add more session hosts
- See `docs/scaling-down.md` for capacity planning guidance

## Cleanup
Delete all resources:
```bash
az group delete --name rg-avd-dev --yes --no-wait
```

Or delete specific deployment:
```bash
az deployment sub delete --name avd-deploy-<timestamp>
```

## Cost Optimization
- **Stop VMs when not in use**: Use Azure Automation or manual shutdown
- **Reduce VM size**: Change `vmSize` to smaller instance if sufficient
- **Reduce host count**: Scale down to 1 host for minimal usage periods
- **Delete entire environment**: When not needed for extended periods

**Estimated Monthly Cost (1 host, part-time use):**
- Standard_D2s_v5: ~$70-140/month (full-time)
- Part-time (8hrs/day, 5 days/week): ~$30-40/month
- See `README.md` for detailed cost breakdown

## Next Steps
- Review `tests/` directory for validation test plans
- See `docs/security-checklist.md` for production hardening
- Explore `docs/outputs.md` for deployment output details
- Add more dev tools to installation script as needed
