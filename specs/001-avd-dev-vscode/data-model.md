# Phase 1 Data Model: Azure Virtual Desktop Dev Environment

**Feature**: `specs/001-avd-dev-vscode/spec.md`
**Derived From**: User stories, functional requirements, research decisions

## Entities & Parameters Mapping

| Entity | Description | Key Attributes | Source Parameters | Notes |
|--------|-------------|----------------|-------------------|-------|
| HostPool | AVD host pool for multi-session | name, loadBalancing, friendlyName, maxSessionsPerHost | `hostPoolName`, `loadBalancingStrategy`, `maxSessionsPerHost` | Registration token generated; expiration param optional |
| SessionHost VM | VM instances joined to host pool | name, size, imageRef, adminUser, hostPoolToken | `hostCount`, `vmSize`, `imagePublisher`, `imageOffer`, `imageSku`, `adminUsername`, `adminPassword` | Loop over `hostCount` |
| CustomImage | Managed image produced by Image Builder | name, versionTag, sourceRef | `imageBuilderEnabled`, `baseImagePublisher`, `baseImageOffer`, `baseImageSku` | If disabled, use marketplace image directly |
| ImageBuilderTemplate | Customization template | sourceImage, customizationScript, outputName | `imageBuilderEnabled`, `vscodeWingetId` | Winget ID defaults to `Microsoft.VisualStudioCode` |
| Workspace | AVD workspace for user access | name, description | `workspaceName` | Single workspace |
| ApplicationGroup | RemoteApp application group | name, type, associatedHostPool | `appGroupName` | Type = RemoteApp |
| RemoteApp (VS Code) | Published VS Code app | displayName, commandPath | `remoteAppDisplayName`, `remoteAppCommandPath` | Path validated via build; default `C:\\Program Files\\Microsoft VS Code\\Code.exe` |
| EntraIDGroupAssignment | Access control mapping | groupObjectId, appGroupId | `entraIdGroupObjectId` | Group must exist pre-deploy |
| VirtualNetwork | Network container | name, addressPrefixes | `vnetName`, `vnetAddressPrefixes` | Single VNet |
| Subnet | Session host subnet | name, addressPrefix | `subnetName`, `subnetAddressPrefix` | Contains hosts |
| RegistrationToken | Temporary token for host registration | tokenValue, expiresOn | derived | Output only |

## Parameter Definitions (Draft)

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
| baseImagePublisher | string | yes | `MicrosoftWindowsDesktop` | Source image publisher |
| baseImageOffer | string | yes | `Windows-11` | Source image offer |
| baseImageSku | string | yes | `win11-22h2-ent-multi-session` | Source image SKU |
| imageBuilderEnabled | bool | no | true | Toggle custom image build |
| vscodeWingetId | string | no | `Microsoft.VisualStudioCode` | Winget ID for VS Code |
| imageNamePrefix | string | no | `devavd` | Prefix for managed image naming |
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
- ImageBuilderTemplate → CustomImage → SessionHost VM (image reference)

## State Transitions

| Entity | State | Trigger | Next State |
|--------|-------|---------|------------|
| ImageBuilderTemplate | building | build start | built |
| CustomImage | built | build success | released |
| SessionHost VM | provisioning | deployment | registered |
| RegistrationToken | active | creation | expired (after hours) |

## Validation Rules
- `hostCount` ≥ 1
- `maxSessionsPerHost` ≥ 1
- `subnetAddressPrefix` must be within `vnetAddressPrefixes`
- Length constraints (names ≤ 64 chars) follow Azure resource limits
- `remoteAppCommandPath` must exist on image (deployment script extension validation optional later)

## Open Points
- Future automation for what-if gating (Phase 2+ enhancement)
- Potential addition of monitoring (Log Analytics) out of scope now

## Notes
Data model stable for Phase 1; contracts will formalize parameter schema.
