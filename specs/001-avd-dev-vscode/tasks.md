# Tasks: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`
**Goal**: Deliver a low-cost AVD environment with VS Code RemoteApp, custom image, manual scaling.

## Format
`[ID] [P?] [Story] Description`
- **[P]**: Can run in parallel (no dependency overlap)
- **[Story]**: US1 (RemoteApp usage), US2 (Image build/update), US3 (Scaling)
- Explicit file paths where applicable

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 [P] Global: Create/confirm resource group (if not already defined) for AVD resources (`rg-avd-dev`) – optional if deploying at subscription scope.
- [ ] T002 [P] Global: Initialize parameter file `src/infra/parameters/dev.bicepparam` with defaults per data-model.
- [ ] T003 Global: Add `install-vscode.ps1` script under `src/infra/scripts/` (winget install).
- [ ] T004 [P] Global: Scaffold AVM module wrapper files under `src/infra/modules/` (hostpool, workspace, appGroup, sessionHostVM, network, image-builder).
- [ ] T005 Global: Refactor `src/infra/main.bicep` to reference module wrappers and expose parameters.

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T006 [P] Global: Implement network module (`modules/network.bicep`) with VNet + Subnet.
- [ ] T007 [P] Global: Implement host pool module (`modules/hostpool.bicep`) with parameters (loadBalancingStrategy, maxSessionsPerHost).
- [ ] T008 [P] Global: Generate short-lived registration token output in host pool module.
- [ ] T009 [P] Global: Implement workspace module (`modules/workspace.bicep`).
- [ ] T010 [P] Global: Implement application group module (`modules/appGroup.bicep`) referencing host pool.
- [ ] T011 Global: Link application group to workspace (main orchestration) ensuring output IDs wired.
- [ ] T012 Global: Validate `parameters.schema.json` against dev.bicepparam (manual or scripted AJV check).
- [ ] T013 Global: Add what-if validation script `scripts/validate-whatif.ps1` (optional future automation placeholder).

**Checkpoint**: Infra skeleton deployable (no session hosts yet, no RemoteApp).

## Phase 3: User Story 1 – Developer Launches VS Code Remote App (P1)

### Tests (OPTIONAL – manual validation focus)
- [ ] T014 [P] US1 Manual test plan doc `tests/US1-remoteapp-validation.md` (launch time, visibility, capacity fail scenario outline).

### Implementation
- [ ] T015 US1: Implement RemoteApp resource inside app group module (path param `remoteAppCommandPath`).
- [ ] T016 [P] US1: Implement session host VM module (`modules/sessionHostVM.bicep`) referencing image and registration token.
- [ ] T017 US1: Add loop in `main.bicep` to create `hostCount` session hosts using sessionHostVM module.
- [ ] T018 US1: Confirm VS Code path (deploy test VM or rely on image customization; adjust if necessary).
- [ ] T019 US1: Document manual assignment verification steps in `quickstart.md` (ensure visibility restricted to group).
- [ ] T020 US1: Deploy full stack and record actual VS Code launch time.

**Checkpoint**: VS Code RemoteApp available & launches ≤ 60s for assigned user.

## Phase 4: User Story 2 – Administrator Builds & Updates Custom Image (P2)

### Tests (OPTIONAL)
- [ ] T021 [P] US2: Image build log review checklist `tests/US2-image-build-checklist.md`.

### Implementation
- [ ] T022 US2: Implement image builder template module (`modules/image-builder.bicep`) with base image params + timestamp naming.
- [ ] T023 US2: Add PowerShell customizer step executing `install-vscode.ps1` (winget install).
- [ ] T024 US2: Output managed image ID + version tag from module.
- [ ] T025 US2: Wire managed image reference into sessionHostVM module (conditional on `imageBuilderEnabled`).
- [ ] T026 US2: Validate image build duration (record actual in research addendum).
- [ ] T027 US2: Document image update procedure in `quickstart.md` (already drafted; refine with outputs).
- [ ] T028 US2: Perform update test (build new image, deploy new host, validate VS Code).

**Checkpoint**: Updated image process repeatable; new host uses latest image with VS Code.

## Phase 5: User Story 3 – Administrator Scales Session Capacity (P3)

### Tests (OPTIONAL)
- [ ] T029 [P] US3: Scaling validation doc `tests/US3-scaling-validation.md` (increase/decrease scenarios).

### Implementation
- [ ] T030 US3: Ensure `hostCount` parameter loop cleanly handles increases (idempotent resource naming strategy).
- [ ] T031 US3: Implement graceful scale-down procedure doc `docs/scaling-down.md` (drain & redeploy).
- [ ] T032 US3: Deploy with `hostCount=2` and record second host registration time.
- [ ] T033 US3: Validate capacity error scenario (simulate host max sessions) and document user feedback.

**Checkpoint**: Scaling up/down works; session reliability maintained.

## Phase 6: Polish & Cross-Cutting

- [ ] T034 [P] Global: Add outputs documentation `docs/outputs.md` (registration token, image ID, workspace/app group IDs).
- [ ] T035 [P] Global: Add minimal tagging across resources (`environment=dev`, `feature=avd-vscode`).
- [ ] T036 Global: Add cost guidance section to `README.md` (monthly estimate assumptions for single host).
- [ ] T037 Global: Run what-if again post full features and capture diff report `docs/whatif-final.md`.
- [ ] T038 Global: Security review checklist `docs/security-checklist.md` (token expiration, principle of least privilege).
- [ ] T039 Global: Final manual validation against success criteria (SC-001..SC-007) `tests/success-criteria-report.md`.

## Dependencies & Execution Order
- Foundational (T006–T013) precedes US1/US2/US3.
- US2 image build must complete before finalizing VS Code path validation (T018) for production image; early path check can use marketplace base as interim.
- Scaling tasks depend on successful host deployment loop (T017).

## Parallel Opportunities
- Network (T006), Host Pool (T007), Workspace (T009), App Group (T010) can proceed in parallel.
- Image builder development (T022–T024) can start during US1 tasks but publish hosts only after image ready.
- Documentation tasks (T019, T027, T031, T034–T036) can be parallel once core modules stable.

## Future (Deferred) Tasks (Not in current scope)
- CI pipeline for automatic what-if gating.
- Log Analytics integration module.
- Additional dev tools (Git, Azure CLI) baked into image.
- Autoscaling logic based on session metrics.

## Completion Criteria
All checkpoints satisfied + success criteria report (T039) completed without unmet mandatory metrics.
