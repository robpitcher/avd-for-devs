# Phase 1 Data Model: Azure Virtual Desktop Dev Environment

**Feature**: `specs/001-avd-dev-vscode/spec.md`
**Derived From**: User stories, functional requirements, research decisions
**Updated**: 2025-11-16 (Reflects marketplace image + script extension architecture)

## Entities & Parameters Mapping

| Entity | Description | Key Attributes | Source Parameters | Notes |
|--------|-------------|----------------|-------------------|-------|
| HostPool | AVD host pool for multi-session | name, loadBalancing, friendlyName, maxSessionsPerHost | `hostPoolName`, `loadBalancingStrategy`, `maxSessionsPerHost` | Registration token generated; expiration param optional |
| SessionHost VM | VM instances joined to host pool | name, size, imageRef, adminUser, hostPoolToken | `hostCount`, `vmSize`, `baseImagePublisher`, `baseImageOffer`, `baseImageSku`, `adminUsername`, `adminPassword` | Loop over `hostCount`; uses marketplace image |
| MarketplaceImageReference | Reference to Azure Marketplace image | publisher, offer, sku, version | `baseImagePublisher`, `baseImageOffer`, `baseImageSku` | Always uses 'latest' version |
| InstallationScript | PowerShell script for VS Code installation | scriptUri, executionCommand, expectedPath | `vscodeInstallScriptUri` | Executed via custom script extension |
| CustomScriptExtension | VM extension for software installation | fileUris, commandToExecute, status | `vscodeInstallScriptUri` | Runs after VM joins host pool |
| Workspace | AVD workspace for user access | name, description | `workspaceName` | Single workspace |
| ApplicationGroup | RemoteApp application group | name, type, associatedHostPool | `appGroupName` | Type = RemoteApp |
| RemoteApp (VS Code) | Published VS Code app | displayName, commandPath | `remoteAppDisplayName`, `remoteAppCommandPath` | Path: `C:\\Program Files\\Microsoft VS Code\\Code.exe` |
| EntraIDGroupAssignment | Access control mapping | groupObjectId, appGroupId | `entraIdGroupObjectId` | Group must exist pre-deploy |
| VirtualNetwork | Network container | name, addressPrefixes | `vnetName`, `vnetAddressPrefixes` | Single VNet |
| Subnet | Session host subnet | name, addressPrefix | `subnetName`, `subnetAddressPrefix` | Contains hosts |
| RegistrationToken | Temporary token for host registration | tokenValue, expiresOn | derived | Output only; 24h expiration |

## Parameter Definitions

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| location | string | yes | canadacentral | Azure region |
| hostPoolName | string | yes | `dev-avd-hostpool` | Host pool name |
| loadBalancingStrategy | string | yes | `BreadthFirst` | Host pool load balancing |
| maxSessionsPerHost | int | no | 10 | Limit per host |
| hostCount | int | yes | 1 | Number of session host VMs |
| vmSize | string | yes | `Standard_D2s_v5` | VM size |
| adminUsername | string | yes | n/a | Local admin username |
| adminPassword | secureString | yes | n/a | Local admin password |
| baseImagePublisher | string | yes | `MicrosoftWindowsDesktop` | Marketplace image publisher |
| baseImageOffer | string | yes | `Windows-11` | Marketplace image offer |
| baseImageSku | string | yes | `win11-22h2-ent-multi-session` | Marketplace image SKU |
| vscodeInstallScriptUri | string | yes | GitHub raw URL | URI to install-vscode.ps1 script |
| workspaceName | string | yes | `dev-avd-ws` | Workspace name |
| appGroupName | string | yes | `dev-avd-appgrp` | Application group name |
| remoteAppDisplayName | string | yes | `Visual Studio Code` | Published app display name |
| remoteAppCommandPath | string | yes | `C:\\Program Files\\Microsoft VS Code\\Code.exe` | Executable path |
| entraIdGroupObjectId | string | yes | n/a | Entra ID group object ID for access |
| vnetName | string | yes | `dev-avd-vnet` | VNet name |
| vnetAddressPrefixes | array(string) | no | ["10.20.0.0/16"] | VNet address space |
| subnetName | string | yes | `dev-avd-subnet` | Subnet name |
| subnetAddressPrefix | string | yes | `10.20.1.0/24` | Subnet prefix |
| registrationTokenExpirationHours | int | no | 24 | Token lifetime |

## Relationships

- HostPool 1..* SessionHost VM (loop creates multiple hosts)
- HostPool 1..1 ApplicationGroup (RemoteApp type)
- ApplicationGroup 1..* RemoteApp (currently 1 VS Code)
- Workspace 1..* ApplicationGroup (currently 1)
- EntraIDGroupAssignment 1..1 ApplicationGroup (visibility control)
- VirtualNetwork 1..1 Subnet; Subnet 1..* SessionHost VM
- MarketplaceImageReference → SessionHost VM (image reference)
- InstallationScript → CustomScriptExtension → SessionHost VM (software installation)

## State Transitions

| Entity | State | Trigger | Next State |
|--------|-------|---------|------------|
| SessionHost VM | provisioning | deployment | joining |
| SessionHost VM | joining | AVD agent install | installing software |
| SessionHost VM | installing software | script extension | registered |
| CustomScriptExtension | pending | VM ready | running |
| CustomScriptExtension | running | script execution | succeeded/failed |
| RegistrationToken | active | creation | expired (after 24 hours) |

## Validation Rules
- `hostCount` ≥ 1
- `maxSessionsPerHost` ≥ 1
- `subnetAddressPrefix` must be within `vnetAddressPrefixes`
- Length constraints (names ≤ 64 chars) follow Azure resource limits
- `vscodeInstallScriptUri` must be accessible (HTTPS recommended)
- `entraIdGroupObjectId` must be valid GUID

## Implementation Notes
- No custom image build phase - uses marketplace images directly
- Script extension executes after VM provisioning and host pool join
- Script failures cause deployment to fail (fail-fast approach)
- VS Code installation path verified by script before completion
- All hosts in deployment use same marketplace image version ('latest' at deployment time)

## Open Points
- Future: Log Analytics integration for script execution monitoring
- Future: Azure Storage account for script hosting (currently GitHub)
- Future: Additional dev tools in installation script (Git, Azure CLI, etc.)

## Notes
Data model reflects implemented architecture using marketplace images with custom script extension. No Image Builder entities needed.
