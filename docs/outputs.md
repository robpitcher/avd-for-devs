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
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.hostPoolId.value -o tsv
```

---

### workspaceId
- **Type**: String
- **Description**: Azure resource ID of the AVD workspace
- **Usage**: Workspace management, application group associations
- **Example**: `/subscriptions/<sub-id>/resourceGroups/rg-avd-dev/providers/Microsoft.DesktopVirtualization/workspaces/dev-avd-ws`

**Access**:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.workspaceId.value -o tsv
```

---

### appGroupId
- **Type**: String
- **Description**: Azure resource ID of the application group (RemoteApp type)
- **Usage**: Role assignments, RemoteApp publishing, user access management
- **Example**: `/subscriptions/<sub-id>/resourceGroups/rg-avd-dev/providers/Microsoft.DesktopVirtualization/applicationGroups/dev-avd-appgrp`

**Access**:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.appGroupId.value -o tsv
```

---

### registrationToken
- **Type**: String (Sensitive)
- **Description**: Short-lived token for joining session hosts to the host pool
- **Expiration**: 24 hours by default (configurable via `registrationTokenExpirationHours`)
- **Usage**: Manual session host registration, troubleshooting
- **Security**: Do not store in logs or share publicly

**Access**:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.registrationToken.value -o tsv
# Use immediately for host registration
```

**Regeneration**:
If expired, redeploy or update the host pool to generate a new token.

---

### sessionHostNames
- **Type**: Array of Strings
- **Description**: Names of all deployed session host VMs provisioned from marketplace image
- **Usage**: Inventory management, monitoring, troubleshooting
- **Example**: `["avd-vm-000", "avd-vm-001"]`

**Access**:
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.sessionHostNames.value
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

### Azure CLI Example: List All Session Hosts
```bash
# Get deployment outputs
SESSION_HOSTS=$(az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.sessionHostNames.value -o tsv)

# List VM details
for VM_NAME in $SESSION_HOSTS; do
  az vm show \
    --resource-group rg-avd-dev \
    --name $VM_NAME \
    --query "{Name:name, Location:location, Size:hardwareProfile.vmSize}"
done
```

### Azure CLI Example: Check Host Pool Status
```bash
# Get host pool ID
HOST_POOL_ID=$(az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs.hostPoolId.value -o tsv)

# Show host pool details
az desktopvirtualization hostpool show \
  --ids $HOST_POOL_ID \
  --output table
```

### Azure CLI Example: Export Outputs to JSON
```bash
az deployment sub show \
  --name avd-deploy-<timestamp> \
  --query properties.outputs > outputs.json
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
**Solution**: Verify deployment completed successfully; check deployment name with `az deployment sub list`

**Issue**: Registration token expired  
**Solution**: Redeploy to generate a new token

**Issue**: Session host names empty  
**Solution**: Check `hostCount` parameter; verify deployment logs for VM creation errors using `az deployment sub show --name <deployment-name>`

## Related Documents
- `quickstart.md` - Deployment procedures
- `scaling-down.md` - Scaling operations using outputs
