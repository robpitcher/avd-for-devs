# Deployment Outputs Documentation

## Overview
This document describes the outputs from the AVD infrastructure deployment and their usage.

## Main Deployment Outputs

### hostPoolId
- **Type**: String
- **Description**: Azure resource ID of the AVD host pool
- **Usage**: Reference for Azure CLI/PowerShell commands, monitoring integrations
- **Example**: `/subscriptions/<sub-id>/resourceGroups/rg-avd-dev/providers/Microsoft.DesktopVirtualization/hostPools/dev-avd-hostpool`

**Access**:
```powershell
$deployment = Get-AzSubscriptionDeployment -Name avd-deploy
$hostPoolId = $deployment.Outputs.hostPoolId.Value
```

---

### workspaceId
- **Type**: String
- **Description**: Azure resource ID of the AVD workspace
- **Usage**: Workspace management, application group associations
- **Example**: `/subscriptions/<sub-id>/resourceGroups/rg-avd-dev/providers/Microsoft.DesktopVirtualization/workspaces/dev-avd-ws`

**Access**:
```powershell
$workspaceId = $deployment.Outputs.workspaceId.Value
```

---

### appGroupId
- **Type**: String
- **Description**: Azure resource ID of the application group (RemoteApp type)
- **Usage**: Role assignments, RemoteApp publishing, user access management
- **Example**: `/subscriptions/<sub-id>/resourceGroups/rg-avd-dev/providers/Microsoft.DesktopVirtualization/applicationGroups/dev-avd-appgrp`

**Access**:
```powershell
$appGroupId = $deployment.Outputs.appGroupId.Value
```

---

### registrationToken
- **Type**: String (Sensitive)
- **Description**: Short-lived token for joining session hosts to the host pool
- **Expiration**: 24 hours by default (configurable via `registrationTokenExpirationHours`)
- **Usage**: Manual session host registration, troubleshooting
- **Security**: Do not store in logs or share publicly

**Access**:
```powershell
$token = $deployment.Outputs.registrationToken.Value
# Use immediately for host registration
```

**Regeneration**:
If expired, redeploy or use:
```powershell
Update-AzWvdHostPool -ResourceGroupName rg-avd-dev -Name dev-avd-hostpool -RegistrationInfoExpirationTime (Get-Date).AddHours(24)
```

---

### customImageName
- **Type**: String
- **Description**: Name of the custom managed image (if `imageBuilderEnabled = true`)
- **Usage**: Reference for image versioning, rollback scenarios
- **Example**: `devavd-202511151200` (timestamp format)

**Access**:
```powershell
$imageName = $deployment.Outputs.customImageName.Value
```

---

### sessionHostNames
- **Type**: Array of Strings
- **Description**: Names of all deployed session host VMs
- **Usage**: Inventory management, monitoring, troubleshooting
- **Example**: `["avd-vm-000", "avd-vm-001"]`

**Access**:
```powershell
$vmNames = $deployment.Outputs.sessionHostNames.Value
```

## Module-Level Outputs

### Network Module
- `vnetId`: Virtual network resource ID
- `subnetId`: Subnet resource ID
- `subnetName`: Subnet name

### Host Pool Module
- `hostPoolId`: Host pool resource ID
- `hostPoolName`: Host pool name
- `registrationToken`: Registration token (sensitive)
- `tokenExpirationTime`: Token expiration timestamp

### Workspace Module
- `workspaceId`: Workspace resource ID
- `workspaceName`: Workspace name

### Application Group Module
- `appGroupId`: Application group resource ID
- `appGroupName`: Application group name

### Session Host VM Module
- `vmId`: Virtual machine resource ID
- `vmName`: Virtual machine name

### RemoteApp Module
- `remoteAppId`: RemoteApp resource ID
- `remoteAppName`: RemoteApp name

### Role Assignment Module
- `roleAssignmentId`: Role assignment resource ID

## Using Outputs in Scripts

### PowerShell Example: List All Session Hosts
```powershell
$deployment = Get-AzSubscriptionDeployment -Name avd-deploy
$vmNames = $deployment.Outputs.sessionHostNames.Value

foreach ($vmName in $vmNames) {
    Get-AzVM -ResourceGroupName rg-avd-dev -Name $vmName | Select-Object Name, Location, VmSize
}
```

### PowerShell Example: Check Host Pool Status
```powershell
$deployment = Get-AzSubscriptionDeployment -Name avd-deploy
$hostPoolId = $deployment.Outputs.hostPoolId.Value

Get-AzWvdHostPool -ResourceId $hostPoolId | Format-List
```

### Azure CLI Example: Export Outputs to JSON
```bash
az deployment sub show --name avd-deploy --query properties.outputs > outputs.json
```

## Security Considerations

1. **Registration Token**:
   - Never commit to source control
   - Rotate regularly (automatic on redeploy)
   - Use short expiration times

2. **Output Access**:
   - Limit deployment read permissions
   - Use Azure Key Vault for long-term storage of sensitive values if needed

3. **Logging**:
   - Ensure CI/CD pipelines mask sensitive outputs
   - Avoid logging `registrationToken` in scripts

## Troubleshooting

**Issue**: Output not found
**Solution**: Verify deployment completed successfully; check deployment name

**Issue**: Registration token expired
**Solution**: Redeploy or regenerate token using `Update-AzWvdHostPool`

**Issue**: Session host names empty
**Solution**: Check `hostCount` parameter; verify deployment logs for VM creation errors

## Related Documents
- `quickstart.md` - Deployment procedures
- `scaling-down.md` - Scaling operations using outputs
