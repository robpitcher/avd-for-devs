# Scaling Down AVD Session Hosts - Procedure

## Overview
This document describes the graceful scale-down procedure for reducing the number of AVD session hosts without disrupting active user sessions.

## Prerequisites
- Azure PowerShell or CLI access
- Permissions to modify session hosts and deploy infrastructure
- Knowledge of current `hostCount` parameter value

## Procedure

### Step 1: Identify Target Host(s) for Removal

Determine which session host(s) to remove based on:
- Lowest current session load
- Age (older hosts first if images updated)
- Alphabetical order for consistency

Example: To scale from 3 to 2 hosts, remove `avd-vm-002`

### Step 2: Enable Drain Mode

**Purpose**: Prevent new sessions from being assigned to the target host.

**Command** (PowerShell):
```powershell
Update-AzWvdSessionHost `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -Name <session-host-name> `
  -AllowNewSession:$false
```

**Example**:
```powershell
Update-AzWvdSessionHost `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -Name avd-vm-002.domain `
  -AllowNewSession:$false
```

### Step 3: Notify Active Users (Optional but Recommended)

**Check for active sessions**:
```powershell
Get-AzWvdUserSession `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -SessionHostName <session-host-name>
```

**Send message to users** (requires AVD admin role):
```powershell
Send-AzWvdUserSessionMessage `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -SessionHostName <session-host-name> `
  -MessageTitle "Maintenance Notice" `
  -MessageBody "This session host will be taken offline in 10 minutes. Please save your work and log off."
```

### Step 4: Wait for Sessions to End

**Monitor active sessions**:
```powershell
# Run periodically until session count = 0
(Get-AzWvdUserSession `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -SessionHostName <session-host-name>).Count
```

**Force logoff** (if deadline reached and users notified):
```powershell
Get-AzWvdUserSession `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -SessionHostName <session-host-name> | ForEach-Object {
    Remove-AzWvdUserSession -ResourceGroupName rg-avd-dev `
      -HostPoolName dev-avd-hostpool `
      -SessionHostName $_.Name `
      -Id $_.Id `
      -Force
}
```

### Step 5: Remove Host from Host Pool (Manual Option)

**Option A**: Remove session host from host pool explicitly:
```powershell
Remove-AzWvdSessionHost `
  -ResourceGroupName rg-avd-dev `
  -HostPoolName dev-avd-hostpool `
  -Name <session-host-name>
```

**Option B**: Proceed to Step 6 and let redeployment handle cleanup (requires infrastructure-as-code discipline).

### Step 6: Update Parameter File and Redeploy

1. Edit `src/infra/parameters/dev.bicepparam`
2. Reduce `hostCount` parameter (e.g., from 3 to 2)
3. Redeploy:
   ```powershell
   New-AzSubscriptionDeployment `
     -Location canadacentral `
     -Name avd-scale-down `
     -TemplateFile .\src\infra\main.bicep `
     -TemplateParameterFile .\src\infra\parameters\dev.bicepparam
   ```

### Step 7: Clean Up Orphaned VMs (If Necessary)

If the Bicep deployment does not automatically delete the removed VM (depending on loop implementation):

```powershell
Remove-AzVM `
  -ResourceGroupName rg-avd-dev `
  -Name avd-vm-002 `
  -Force
```

Also remove associated resources:
- Network interface: `avd-vm-002-nic`
- OS disk: `avd-vm-002-osdisk`

### Step 8: Verify Final State

**Check host pool**:
```powershell
Get-AzWvdSessionHost -ResourceGroupName rg-avd-dev -HostPoolName dev-avd-hostpool
```

**Expected**: Only the intended number of hosts remain (e.g., 2 if scaled down from 3).

## Best Practices

1. **Schedule during low-usage windows** (evenings/weekends).
2. **Communicate in advance** with users if possible.
3. **Document which hosts were removed** for audit purposes.
4. **Test scale-down in non-production** environment first.
5. **Monitor remaining hosts** for increased load after scale-down.

## Rollback

If issues arise, immediately scale back up:
1. Increase `hostCount` in parameter file
2. Redeploy
3. New host(s) will provision and register

## Automation Opportunities (Future)

- Script to automate drain + wait + remove cycle
- Integration with monitoring to trigger scale-down based on low utilization
- CI/CD pipeline with approval gates for scale operations

## Related Documents
- `tests/US3-scaling-validation.md` - Scaling test procedures
- `quickstart.md` - Deployment and parameter management
