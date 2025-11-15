# Implementation Plan: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Branch**: `001-avd-dev-vscode` | **Date**: 2025-11-15 | **Spec**: `specs/001-avd-dev-vscode/spec.md`
**Input**: Feature specification from `specs/001-avd-dev-vscode/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Provision a low-cost Azure Virtual Desktop (AVD) proof-of-concept environment for developers: one host pool, single RemoteApp (Visual Studio Code), custom Windows 11 Enterprise multi-session image built via Azure Image Builder to pre-install VS Code, Entra ID group-based access, parameter-driven manual scaling (host count). Infrastructure delivered using Azure Bicep leveraging Azure Verified Modules (AVM) where available. Excludes FSLogix and Office to minimize cost and complexity.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Azure Bicep (latest), PowerShell (Az module)
**Primary Dependencies**: Azure Verified Modules (AVM) for Desktop Virtualization resources, Compute (VM), Network (VNet/Subnet); Azure Image Builder; winget (inside customization)
**Storage**: N/A (no persistent app data; OS disk only)
**Testing**: Manual validation + `az deployment what-if` for template drift; Potential future automated deployment test (NEEDS CLARIFICATION: decide if what-if gating becomes mandatory)
**Target Platform**: Azure (canadacentral default region)
**Project Type**: Single IaC project (infra only)
**Performance Goals**: VS Code RemoteApp launch ≤ 60s (spec SC-001); Image build ≤ 20m end-to-end (spec SC-002)
**Constraints**: Minimize cost (single D2s_v5 by default); No FSLogix; Keep template under ~300 lines excluding modules
**Scale/Scope**: Baseline 5 concurrent devs; Param scaling to small number (1–3 hosts)

Clarifications Needed:
- AVM module names exact versions (NEEDS CLARIFICATION) – Phase 0
- Exact base image reference for Windows 11 multi-session (NEEDS CLARIFICATION) – Phase 0
- VS Code install method in Image Builder (winget vs direct download) (NEEDS CLARIFICATION) – Phase 0
- Registration token lifecycle management strategy (rotate vs long-lived) (NEEDS CLARIFICATION) – Phase 0
- what-if enforcement policy in CI (NEEDS CLARIFICATION) – Phase 0

## Phase 0 Resolution Summary (Post-Research)
Resolved clarifications:
1. AVM modules: adopt latest stable; pin versions during implementation commit.
2. Base image: `MicrosoftWindowsDesktop:Windows-11:win11-22h2-ent-multi-session`.
3. VS Code install: winget `Microsoft.VisualStudioCode` in Image Builder PowerShell customizer.
4. Registration token: short-lived (24h default) regenerated on scaling if expired.
5. CI what-if: deferred; manual command documented in quickstart.

No remaining blockers for Phase 1 deliverables.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution file is placeholder; provisional principles inferred for gating:
1. Simplicity & Cost Efficiency – Single host pool, minimal services.
2. Reproducibility – All infra declared; image customization scripted.
3. Access Control – Entra ID group assignment only.
4. Observability (minimal) – Deployment outputs + build logs accessible.
5. Versioning – Image versions tagged; template parameters pinned.

Initial Gate Evaluation:
- No unjustified complexity (PASS)
- Clear scope boundaries documented (PASS)
- Test strategy outlined (Manual + what-if; automation TBD) (PARTIAL – pending clarification)
- All clarifications listed for Phase 0 resolution (PASS)

Proceed to Phase 0 with noted clarifications.

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
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
src/
└── infra/
  ├── main.bicep                # Entry point referencing modules
  ├── image-builder.bicep       # Image Builder definition (or inline in main)
  ├── modules/                  # AVM module wrappers / additions (if needed)
  │   ├── hostpool.bicep
  │   ├── workspace.bicep
  │   ├── appGroup.bicep
  │   ├── sessionHostVM.bicep
  │   └── network.bicep
  ├── parameters/               # Example parameter files
  │   └── dev.bicepparam
  └── scripts/                  # Image customizer scripts (PowerShell)
    └── install-vscode.ps1

tests/ (future)
└── what-if/                      # Potential automation for validation
```

**Structure Decision**: Single IaC project under `src/infra` with modular decomposition for clarity & reuse; existing repository already contains `src/infra/main.bicep` which will be refactored to call AVM modules + image builder template + remote app definitions. Scripts added for image customization.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
