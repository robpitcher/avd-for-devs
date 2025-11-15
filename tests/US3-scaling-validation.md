# US3 Scaling Validation - Test Guide

**User Story**: Administrator scales session capacity
**Success Criteria**: SC-007 (Parameter-driven scaling), SC-005 (Capacity error handling)

## Test Environment

### Prerequisites
- AVD environment deployed with initial `hostCount=1`
- Access to parameter file (`dev.bicepparam`)
- Azure PowerShell or CLI configured

## Scale-Up Testing

### TC-001: Scale from 1 to 2 Session Hosts (SC-007)

**Objective**: Verify idempotent scaling by increasing host count

**Steps**:
1. Verify current deployment has 1 session host
   ```powershell
   Get-AzWvdSessionHost -ResourceGroupName rg-avd-dev -HostPoolName dev-avd-hostpool
   ```
2. Update parameter file: `hostCount = 2`
3. Record start time
4. Redeploy infrastructure:
   ```powershell
   New-AzSubscriptionDeployment -Location canadacentral -Name avd-scale-up -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\src\infra\parameters\dev.bicepparam
   ```
5. Record completion time
6. Verify 2 session hosts registered

**Expected Result**:
- Deployment succeeds
- Second host provisions and registers
- First host remains untouched
- Both hosts appear in host pool

**Measurements**:
- Scale-up duration: ______ minutes
- Second host registration time: ______ seconds
- Both hosts healthy: ☐ Yes ☐ No

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

### TC-002: Load Distribution Across Hosts

**Objective**: Verify BreadthFirst load balancing

**Prerequisites**: 2 session hosts deployed (TC-001 complete)

**Steps**:
1. Launch VS Code RemoteApp as Test User 1
2. Check which host received the session:
   ```powershell
   Get-AzWvdUserSession -ResourceGroupName rg-avd-dev -HostPoolName dev-avd-hostpool
   ```
3. Launch VS Code as Test User 2
4. Verify second user assigned to different host (if first host not at max)

**Expected Result**:
- Users distributed across both hosts
- BreadthFirst strategy evident

**Distribution**:
- Host 1 sessions: ______
- Host 2 sessions: ______

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

## Scale-Down Testing

### TC-003: Graceful Scale-Down (Drain & Redeploy)

**Objective**: Verify procedure for reducing host count

**Procedure Documented**: `docs/scaling-down.md`

**Steps**:
1. Enable drain mode on target host (e.g., `avd-vm-001`):
   ```powershell
   Update-AzWvdSessionHost -ResourceGroupName rg-avd-dev -HostPoolName dev-avd-hostpool -Name avd-vm-001 -AllowNewSession:$false
   ```
2. Wait for active sessions to end (or forcibly log off users with notice)
3. Verify no active sessions on drained host:
   ```powershell
   Get-AzWvdUserSession -ResourceGroupName rg-avd-dev -HostPoolName dev-avd-hostpool -SessionHostName avd-vm-001
   ```
4. Update parameter file: `hostCount = 1`
5. Redeploy (note: may need manual VM deletion or use conditional deployment logic)
6. Verify only 1 host remains in host pool

**Expected Result**:
- No user disruption during drain
- Clean removal of drained host
- Remaining host continues serving users

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

## Capacity Error Testing

### TC-004: Simulate Capacity Limit (SC-005)

**Objective**: Verify capacity error when all hosts at max sessions

**Prerequisites**:
- Know `maxSessionsPerHost` (default: 10)
- Sufficient test accounts or session simulation

**Steps**:
1. Deploy with `hostCount=1` and `maxSessionsPerHost=2` (for easier testing)
2. Launch VS Code as Test User 1 → should succeed
3. Launch VS Code as Test User 2 → should succeed
4. Attempt to launch VS Code as Test User 3 (exceeds capacity)
5. Observe error message or wait queue

**Expected Result**:
- First 2 sessions: Successful
- Third session: Error message indicating capacity reached OR queued

**Actual Behavior**:
- Error message: ______
- Queue behavior: ______

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

## Idempotency Testing

### TC-005: Redeploy with Same hostCount

**Objective**: Verify no unnecessary changes on re-deployment

**Steps**:
1. Deploy with `hostCount=2`
2. Without parameter changes, redeploy
3. Check Azure deployment logs for changes

**Expected Result**:
- No resources modified
- Deployment completes quickly (no provisioning)
- "No changes" or "Up to date" message

**Status**: ☐ Pass ☐ Fail
**Notes**:

---

## Success Criteria Validation

| Criteria | Target | Actual | Pass/Fail |
|----------|--------|--------|-----------|
| SC-007: Parameter scaling | `hostCount` param works | ☐ Yes | ☐ Pass ☐ Fail |
| SC-005: Capacity error | Clear error/queue | ☐ Yes | ☐ Pass ☐ Fail |
| Idempotent naming | No conflicts | ☐ Yes | ☐ Pass ☐ Fail |
| Scale-up time | < 15 min (guideline) | _____ min | ☐ Pass ☐ Fail |

## Summary

**Scale-Up**: ☐ Pass ☐ Fail
**Scale-Down**: ☐ Pass ☐ Fail
**Capacity Handling**: ☐ Pass ☐ Fail

**Overall Assessment**: ☐ Pass ☐ Fail

**Tested By**: ______
**Date**: ______
