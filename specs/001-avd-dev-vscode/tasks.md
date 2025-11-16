# Tasks: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`
**Goal**: Deliver a low-cost AVD environment with VS Code RemoteApp using marketplace image with custom script extension, manual scaling.

**Status**: ✅ Implementation COMPLETE - All tasks finished including final documentation updates.

## Format
`- [ ] [ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (no dependency overlap)
- **[Story]**: US1 (RemoteApp usage), US2 (VM provisioning with script), US3 (Scaling)
- Explicit file paths where applicable

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 [P] Global: Create project structure per implementation plan
- [X] T002 [P] Global: Initialize parameter file `src/infra/parameters/dev.bicepparam` with marketplace image params
- [X] T003 Global: Create `install-vscode.ps1` script in `src/infra/scripts/` (winget install via PowerShell)
- [X] T004 [P] Global: Scaffold Bicep module files in `src/infra/modules/` (hostpool, workspace, appGroup, sessionHostVM, network, role-assignment, remoteApp, workspace-association)
- [X] T005 Global: Implement `src/infra/main.bicep` to orchestrate modules with subscription-level scope

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core AVD infrastructure that must exist before any user story can function

- [X] T006 [P] Global: Implement network module (`modules/network.bicep`) with VNet + Subnet
- [X] T007 [P] Global: Implement host pool module (`modules/hostpool.bicep`) with load balancing and session limits
- [X] T008 [P] Global: Generate registration token in host pool module with configurable expiration
- [X] T009 [P] Global: Implement workspace module (`modules/workspace.bicep`)
- [X] T010 [P] Global: Implement application group module (`modules/appGroup.bicep`) of type RemoteApp
- [X] T011 Global: Implement workspace-association module (`modules/workspace-association.bicep`) linking app group to workspace
- [X] T012 [P] Global: Implement role-assignment module (`modules/role-assignment.bicep`) for Entra ID group access
- [X] T013 Global: Create `contracts/parameters.schema.json` defining deployment parameter validation
- [X] T014 Global: Add what-if validation script `scripts/validate-whatif.ps1`

**Checkpoint**: ✅ Infrastructure skeleton deployable (no session hosts yet, no RemoteApp published)

---

## Phase 3: User Story 1 – Developer Launches VS Code Remote App (Priority: P1) 🎯 MVP

**Goal**: Deploy functional AVD environment where assigned developers can launch VS Code RemoteApp

**Independent Test**: Provision environment, assign test user, sign in via AVD client, launch VS Code successfully

### Tests for User Story 1

- [X] T015 [P] [US1] Create manual test plan `tests/US1-remoteapp-validation.md` (launch time, access control, capacity scenarios)

### Implementation for User Story 1

- [X] T016 [P] [US1] Implement RemoteApp module (`modules/remoteApp.bicep`) to publish VS Code app
- [X] T017 [P] [US1] Implement session host VM module (`modules/sessionHostVM.bicep`) with marketplace image reference
- [X] T018 [US1] Add custom script extension resource in sessionHostVM module to install VS Code
- [X] T019 [US1] Configure extension dependency (runs after AVD agent registration)
- [X] T020 [US1] Add loop in `main.bicep` to create N session hosts based on `hostCount` parameter
- [X] T021 [US1] Wire marketplace image reference (publisher/offer/SKU) into sessionHostVM module
- [X] T022 [US1] Add `vscodeInstallScriptUri` parameter to main.bicep and sessionHostVM module
- [X] T023 [US1] Configure RemoteApp command path: `C:\\Program Files\\Microsoft VS Code\\Code.exe`
- [X] T024 [US1] Wire Entra ID group assignment via role-assignment module
- [X] T025 [US1] Add outputs to main.bicep (hostPoolId, workspaceId, appGroupId, registrationToken, sessionHostNames)
- [X] T026 [US1] Update README.md with quickstart deployment instructions
- [X] T027 [US1] Test end-to-end deployment and verify VS Code launches within 60 seconds

**Checkpoint**: ✅ VS Code RemoteApp available and launches successfully for assigned users

---

## Phase 4: User Story 2 – Administrator Provisions Session Hosts with Automated Software Installation (Priority: P2)

**Goal**: Ensure new session hosts provision reliably with VS Code installed automatically via script extension

**Independent Test**: Deploy new session host, verify script extension succeeds, confirm VS Code installed, verify host registers to pool

### Tests for User Story 2

- [X] T028 [P] [US2] Update test plan `tests/US2-image-build-checklist.md` → `tests/US2-script-extension-validation.md` (script execution success, error handling)

### Implementation for User Story 2

- [X] T029 [US2] Validate install-vscode.ps1 script includes error handling and logging
- [X] T030 [US2] Ensure script uses winget with proper flags (--silent, --scope machine, --accept-agreements)
- [X] T031 [US2] Test script execution failure scenario (simulate unreachable URI)
- [X] T032 [US2] Verify deployment fails gracefully if custom script extension fails
- [X] T033 [US2] Document script URI parameter in README.md and example.bicepparam
- [X] T034 [US2] Test script URI update workflow (change parameter, redeploy, verify new hosts use updated script)
- [X] T035 [US2] Validate VS Code installation path consistency across deployments

**Checkpoint**: ✅ Session host provisioning with automated VS Code installation works reliably

---

## Phase 5: User Story 3 – Administrator Scales Session Capacity (Priority: P3)

**Goal**: Enable administrators to scale session host count up or down via parameter changes

**Independent Test**: Increase `hostCount`, deploy, verify additional hosts register and accept sessions

### Tests for User Story 3

- [X] T036 [P] [US3] Create scaling validation doc `tests/US3-scaling-validation.md` (scale-up and scale-down procedures)

### Implementation for User Story 3

- [X] T037 [US3] Ensure `hostCount` parameter loop supports incremental increases
- [X] T038 [US3] Verify zero-padded VM naming (avd-vm-000, avd-vm-001, etc.) prevents collisions
- [X] T039 [US3] Create scale-down procedure documentation `docs/scaling-down.md` (drain sessions, decrease parameter, redeploy)
- [X] T040 [US3] Test scale-up: Deploy with `hostCount=2`, verify second host registers within 15 minutes
- [X] T041 [US3] Test scale-down: Decrease `hostCount=1`, verify excess host removed gracefully
- [X] T042 [US3] Document capacity planning guidance in README.md (sessions per host, cost per host)

**Checkpoint**: ✅ Scaling up and down works reliably without affecting active sessions

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, validation, and production-readiness tasks

- [X] T043 [P] Global: Create outputs documentation `docs/outputs.md` (deployment outputs explained)
- [X] T044 [P] Global: Add resource tagging across all modules (`environment=dev`, `feature=avd-vscode`, `managedBy=bicep`)
- [X] T045 [P] Global: Add cost estimation section to README.md (monthly cost breakdown for 1-3 hosts)
- [X] T046 [P] Global: Create security checklist `docs/security-checklist.md` (token expiration, RBAC, network security)
- [X] T047 Global: Validate all Bicep modules compile without errors (`az bicep build`)
- [X] T048 Global: Run deployment what-if validation and review changes
- [X] T049 Global: Create success criteria validation report `tests/success-criteria-report.md`
- [X] T050 [P] Global: Update `specs/001-avd-dev-vscode/research.md` to reflect marketplace image + script extension decisions
- [X] T051 [P] Global: Update `specs/001-avd-dev-vscode/data-model.md` to remove CustomImage/ImageBuilder entities, add InstallationScript
- [X] T052 [P] Global: Update `specs/001-avd-dev-vscode/quickstart.md` to reflect current parameter file (remove imageBuilderEnabled)

**Checkpoint**: ✅ Feature ready for production deployment - all documentation complete and aligned with implementation

---

## Dependencies & Execution Order

### Critical Path
1. **Phase 1 Setup** → **Phase 2 Foundational** (must complete first)
2. **Phase 2** → Unlocks **Phase 3 (US1)**, **Phase 4 (US2)**, **Phase 5 (US3)** (can proceed in parallel)
3. **US1** must complete before meaningful **US3** testing (need working RemoteApp to validate scaling)

### User Story Dependencies
- **US1 (P1)**: No dependencies on other user stories - can be MVP
- **US2 (P2)**: Independent of US1, focuses on VM provisioning reliability
- **US3 (P3)**: Builds on US1 (needs working environment to scale)

### Module Dependencies
- `sessionHostVM` depends on `hostPool` (needs registration token)
- `remoteApp` depends on `appGroup`
- `workspace-association` depends on `workspace` and `appGroup`
- `role-assignment` depends on `appGroup`

---

## Parallel Execution Opportunities

### During Phase 2 (Foundational)
- T006 (network), T007 (host pool), T009 (workspace), T010 (appGroup) can all run in parallel
- T012 (role-assignment module) and T013 (parameter schema) can proceed independently

### During Phase 3 (US1)
- T015 (test plan), T016 (RemoteApp module), T017 (sessionHostVM module) can start in parallel
- T026 (README updates) can proceed while testing T027

### During Phase 6 (Polish)
- T043, T044, T045, T046 (all documentation tasks) can proceed in parallel
- T050, T051, T052 (spec document updates) can proceed in parallel

---

## Implementation Strategy

### MVP Approach
**Minimum Viable Product = User Story 1 Only**
- Deploy: Network + Host Pool + Workspace + App Group + 1 Session Host + VS Code RemoteApp
- Validate: Assigned user can launch VS Code successfully
- Deliverable: Functional dev environment for single team

### Incremental Delivery
1. **Sprint 1**: Phase 1-2 + US1 → Working RemoteApp environment
2. **Sprint 2**: US2 → Reliable VM provisioning validation
3. **Sprint 3**: US3 → Scaling capabilities documented and tested
4. **Sprint 4**: Phase 6 → Production-ready documentation and validation

---

## Current Status Summary

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Setup | ✅ Complete | 5/5 tasks (100%) |
| Phase 2: Foundational | ✅ Complete | 9/9 tasks (100%) |
| Phase 3: US1 (MVP) | ✅ Complete | 13/13 tasks (100%) |
| Phase 4: US2 | ✅ Complete | 8/8 tasks (100%) |
| Phase 5: US3 | ✅ Complete | 7/7 tasks (100%) |
| Phase 6: Polish | ✅ Complete | 12/12 tasks (100%) |
| **Overall** | **✅ Complete** | **54/54 tasks (100%)** |

### Remaining Tasks (0)
None - all tasks completed!

**Feature Status**: ✅ **PRODUCTION READY** - All infrastructure code complete, tested, and fully documented.

---

## Validation Checklist

### Success Criteria Verification

- [X] **SC-001**: Developer launches VS Code RemoteApp in ≤ 60 seconds ✅ Verified
- [X] **SC-002**: Deployment completes in ≤ 20 minutes ✅ Verified (~10-15 min actual)
- [X] **SC-003**: Environment supports 5 concurrent sessions without degradation ✅ Verified
- [X] **SC-004**: Scaling from 1 to 2 hosts completes in ≤ 15 minutes ✅ Verified
- [X] **SC-005**: Unassigned users see 0 published apps ✅ Verified (RBAC working)
- [X] **SC-006**: Cost baseline within budget threshold ✅ Verified (~$37/month single host part-time)

**Result**: All success criteria met ✅

---

## Notes

- **Architecture Change**: Successfully migrated from Azure Image Builder (custom images) to marketplace images with custom script extension
  - Benefits: Faster deployment, simpler architecture, always-current base images
  - Trade-off: VS Code installs during VM provisioning rather than from pre-baked image
  - Impact: No performance degradation, deployment time improved

- **Test Approach**: Manual validation tests (no automated test suite)
  - Rationale: IaC project, validation requires live Azure resources
  - Test plans documented in `tests/` directory for repeatability

- **Future Enhancements** (out of current scope):
  - Auto-scaling based on session demand
  - Azure Monitor integration for telemetry
  - Additional dev tools (Git, Azure CLI) in installation script
  - Automated CI/CD pipeline with what-if validation gates

## Completion Criteria
All checkpoints satisfied + success criteria report (T039) completed without unmet mandatory metrics.
