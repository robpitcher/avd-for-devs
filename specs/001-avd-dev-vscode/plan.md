# Implementation Plan: AVD Dev Environment with VS Code RemoteApp

**Branch**: `001-avd-dev-vscode` | **Date**: 2025-11-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-avd-dev-vscode/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Deploy an Azure Virtual Desktop environment with Windows 11 Enterprise multi-session marketplace image, automated VS Code installation via custom script extension, Entra ID authentication, and RemoteApp publishing for cost-effective developer access.

## Technical Context

**Language/Version**: Bicep (Azure IaC), PowerShell 7.x
**Primary Dependencies**: Azure Resource Manager, Azure Virtual Desktop service, Windows 11 Multi-session marketplace image
**Storage**: N/A (VM managed disks only)
**Testing**: Manual validation tests (see tests/ directory), Bicep what-if validation
**Target Platform**: Azure Cloud (default region: canadacentral)
**Project Type**: Infrastructure as Code (IaC) deployment
**Performance Goals**: ≤ 20 min deployment, ≤ 60 sec app launch, 5 concurrent users on default VM
**Constraints**: Cost minimization (<$50/month for single host part-time use), no FSLogix, RemoteApp only
**Scale/Scope**: PoC-level (1-3 session hosts, 5-15 concurrent developers maximum)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ PASS (No constitution file violations - using placeholder constitution template)

**Note**: Project does not have a populated constitution file (`.specify/memory/constitution.md` contains only template). No specific gates to enforce at this time. Standard best practices apply:
- Cost optimization (minimize default deployment cost)
- Security baseline (Entra ID auth, group-based access control)
- Maintainability (modular Bicep, parameterized deployment)
- Documentation (README, quickstart, test plans already present)

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
avd-for-devs/
├── src/infra/                  # Infrastructure as Code (Bicep)
│   ├── main.bicep              # Main subscription-level template
│   ├── modules/                # Modular Bicep components
│   │   ├── network.bicep       # VNet and subnet
│   │   ├── hostpool.bicep      # AVD host pool resource
│   │   ├── workspace.bicep     # AVD workspace resource
│   │   ├── appGroup.bicep      # Application group (RemoteApp)
│   │   ├── workspace-association.bicep  # Links app group to workspace
│   │   ├── remoteApp.bicep     # VS Code app publishing
│   │   ├── sessionHostVM.bicep # Session host VMs with custom script extension
│   │   └── role-assignment.bicep  # Entra ID group RBAC
│   ├── parameters/             # Environment parameter files
│   │   ├── dev.bicepparam      # Development environment config
│   │   └── example.bicepparam  # Template for new environments
│   └── scripts/                # VM customization scripts
│       └── install-vscode.ps1  # VS Code installation via winget
├── tests/                      # Manual validation test plans
│   ├── US1-remoteapp-validation.md
│   ├── US2-image-build-checklist.md  # (Needs update for script extension)
│   ├── US3-scaling-validation.md
│   └── success-criteria-report.md
├── docs/                       # User-facing documentation
│   ├── outputs.md
│   ├── scaling-down.md
│   └── security-checklist.md
├── specs/001-avd-dev-vscode/   # This feature's specification
│   ├── spec.md                 # Feature specification (updated)
│   ├── plan.md                 # This implementation plan
│   ├── research.md             # (To be generated - Phase 0)
│   ├── data-model.md           # (To be generated - Phase 1)
│   ├── quickstart.md           # (To be generated - Phase 1)
│   └── contracts/              # (To be generated - Phase 1)
├── scripts/                    # Repository automation
│   └── validate-whatif.ps1     # Deployment validation script
└── README.md                   # Project overview (updated)
```

**Structure Decision**: IaC-focused repository using Bicep modules pattern. Infrastructure code already exists and has been updated to use marketplace images with custom script extension instead of Azure Image Builder. Documentation and test plans need minor updates to reflect the script extension approach.

## Complexity Tracking

**Status**: N/A (No constitution violations to justify)
