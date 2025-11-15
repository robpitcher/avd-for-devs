# Feature Specification: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Feature Branch**: `001-avd-dev-vscode`  
**Created**: 2025-11-15  
**Status**: Draft  
**Input**: User description: "Azure Virtual Desktop dev environment with Entra ID auth, single host pool, latest Win11 multi-session custom image (VS Code added via Image Builder), publish VS Code remote app, exclude FSLogix, use Azure Verified Modules in Bicep"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Developer Launches VS Code Remote App (Priority: P1)

A developer signs in with Entra ID credentials, sees the published "Visual Studio Code" remote app in the workspace, launches it, and receives a functional Windows 11 multi-session session with VS Code pre-installed and ready for coding (no manual install required).

**Why this priority**: This is the core value proposition—quick, low-cost, ready-to-use development environment. Without this, the feature delivers no direct user value.

**Independent Test**: Provision environment, assign a test Entra ID user to the application group, sign in via AVD client/portal, verify VS Code launches successfully within a session and can open a sample folder.

**Acceptance Scenarios**:

1. **Given** environment deployed and user assigned, **When** user signs in and selects VS Code app, **Then** session establishes and VS Code window appears within 60 seconds.
2. **Given** an unassigned user, **When** they sign in, **Then** VS Code remote app is not visible.
3. **Given** session host is at capacity (max concurrent sessions reached by design assumption), **When** new user attempts launch, **Then** user receives a clear capacity message (not silent failure) and retry later guidance.

---
### User Story 2 - Administrator Builds & Updates Custom Image (Priority: P2)

An administrator triggers a custom image build pipeline (Image Builder template) that produces an updated Windows 11 multi-session image including VS Code. After validation, new session hosts (or replacements) use the updated image version; existing sessions continue until users log off.

**Why this priority**: Ensures maintainability and repeatability of the development environment with updated base images and VS Code versions.

**Independent Test**: Execute image build process, confirm resulting managed image includes VS Code executable, deploy a fresh test session host referencing new image version, launch VS Code successfully.

**Acceptance Scenarios**:

1. **Given** a build request, **When** image builder runs successfully, **Then** a new managed image version is available and tagged with build timestamp.
2. **Given** image build failure, **When** pipeline completes, **Then** no host pool image version change occurs and failure reason is captured in build output.
3. **Given** a new image version, **When** host replacement is triggered, **Then** new host registers to host pool and publishes VS Code app without manual software installation.

---
### User Story 3 - Administrator Scales Session Capacity (Priority: P3)

Administrator adjusts capacity (number of session hosts) via parameter change or documented scaling step to accommodate more concurrent developers while preserving cost efficiency.

**Why this priority**: Supports growth / peak usage while keeping baseline minimal cost.

**Independent Test**: Increase desired host count parameter, deploy/scale process runs, additional session host registers and remote app launches successfully for a new test user.

**Acceptance Scenarios**:

1. **Given** desired host count increased, **When** deployment completes, **Then** additional host(s) appear in host pool and accept sessions.
2. **Given** desired host count decreased, **When** scaling operation executes, **Then** excess hosts are drained (no active sessions) and removed without affecting ongoing sessions.
3. **Given** scaling request beyond documented limit (assumption threshold), **When** operation attempted, **Then** user receives guidance to reassess sizing rather than silent failure.

---

Additional user stories may be added for telemetry or developer tooling later; current scope intentionally minimal for cost control.

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- Image build fails due to base image deprecation: Build should abort gracefully and surface clear failure reason; previous image remains active.
- Session host unavailable (maintenance/restart): User attempting to launch app is routed to another available host; if none available capacity message displayed.
- Concurrent user demand exceeds single host capacity: Clear capacity feedback; scaling guidance documented.
- New Windows 11 multi-session version released: Assumption—image builder template parameter updated in next maintenance cycle; no forced immediate redeploy.
- Entra ID group assignment delayed propagation: User cannot see app until group membership propagates; documented expected delay.
- VS Code process crash mid-session: User can relaunch app within same session; session host remains registered.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: Environment MUST provide a single host pool suitable for multi-session developer use.
- **FR-002**: Remote app list MUST include a published Visual Studio Code application accessible only to assigned Entra ID users.
- **FR-003**: Image build process MUST produce a Windows 11 multi-session image with VS Code pre-installed (no user install required).
- **FR-004**: Deployment MUST allow parameterized selection of VM size (default: cost-efficient general-purpose size) and host count (default: 1).
- **FR-005**: Environment MUST exclude FSLogix configuration (explicitly out of scope) while still permitting roaming profiles via default mechanisms if needed.
- **FR-006**: Access MUST be controlled via Entra ID group assignment to the application group; unassigned users MUST NOT see the app.
- **FR-007**: Scaling operation MUST allow increasing or decreasing host count without manual per-host configuration (idempotent deployment).
- **FR-008**: Image update process MUST allow rolling introduction (new hosts join using new image while existing sessions drain).
- **FR-009**: Deployment artifacts MUST minimize cost by default (single host, modest VM size, no premium add-ons).
- **FR-010**: Published app session MUST launch VS Code within 60 seconds of user selection under nominal load.
- **FR-011**: Build process MUST surface clear status (success/failure) and retain latest successful image reference.
- **FR-012**: Environment MUST provide a documented parameter or variable for region selection (default assumption: eastus for availability + cost).
- **FR-013**: No Office apps will be included; image MUST not install Office 365 components.
- **FR-014**: Security baseline MUST rely on default Windows 11 multi-session hardening + Entra ID conditional access (advanced policies out of current scope but can be layered later).
- **FR-015**: Application group MUST be of RemoteApp type (not desktop) publishing only VS Code initially.

### Key Entities *(include if feature involves data)*

- **HostPool**: Logical grouping for session hosts; attributes: name, load balancing strategy, max session limits, registration token validity.
- **SessionHost VM**: Compute instance joined to host pool; attributes: name, size, image version, session capacity.
- **CustomImage**: Managed image output of image builder template; attributes: base image reference, build timestamp, version tag.
- **ImageBuilderTemplate**: Defines customization steps to add VS Code; attributes: source image, customizer steps, distribution targets.
- **Workspace**: End-user entry point presenting published RemoteApp.
- **ApplicationGroup (RemoteApp)**: Collection of published applications; attributes: type, list of apps; contains VS Code app definition.
- **RemoteApp (VS Code)**: The single published application; attributes: display name, command path.
- **EntraIDGroupAssignment**: Mapping between Entra ID group and application group; governs visibility.
- **VirtualNetwork/Subnet**: Network placement for session hosts; attributes: name, address space.

## Success Criteria *(mandatory)*

<!--
  Defined measurable success criteria (technology-agnostic, user/business oriented)
-->

### Measurable Outcomes

- **SC-001**: A first-time developer can sign in and launch VS Code remote app in ≤ 60 seconds after selecting it (excluding initial sign-in MFA time).
- **SC-002**: Default deployment completes (host pool + single host + app publish + image customization prebuilt) in ≤ 20 minutes end-to-end.
- **SC-003**: Image build (customization adding VS Code) succeeds in ≥ 95% of attempts over a 3-build sample (failures captured with actionable reason).
- **SC-004**: Environment supports at least 5 concurrent developer sessions on default size without degraded launch time (> 60 seconds).
- **SC-005**: Scaling host count from 1 to 2 completes and second host registers in ≤ 15 minutes.
- **SC-006**: Unassigned users see 0 published apps (visibility control) in 100% of access tests.
- **SC-007**: Cost baseline for default single host configuration remains within assumed monthly budget threshold (documented externally) enabling PoC viability.

## Assumptions

- Region default: eastus (cost + availability) unless overridden.
- Concurrency target: 5 developers for PoC baseline; scaling beyond requires explicit sizing review.
- VM size default assumption: Standard_D2s_v5 (or equivalent) for cost efficiency.
- Load balancing strategy: breadth-first (maximize utilization of single host) unless policy requires depth-first later.
- Conditional Access and advanced security policies considered additive post-PoC, not blocking initial deployment.

## Out of Scope

- FSLogix profile containers.
- Office 365 application suite.
- Multi-app publishing (only VS Code initially).
- Automated autoscaling logic (manual parameter-driven scaling only).
- Advanced monitoring/telemetry dashboards (basic operational logs acceptable).

## Risks & Mitigations

- Base image version deprecation could break build: Mitigation—document periodic review cadence and update source image parameter.
- Underestimated session capacity causing slow launches: Mitigation—provide sizing guidance and manual scaling procedure.
- Image build customization failure due to tooling path changes: Mitigation—keep customization steps minimal and version pinned where possible.
