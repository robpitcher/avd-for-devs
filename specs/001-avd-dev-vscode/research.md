# Phase 0 Research: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Date**: 2025-11-15
**Feature**: `specs/001-avd-dev-vscode/spec.md`

## Clarifications & Decisions

### 1. AVM Module Versions (NEEDS CLARIFICATION)
- **Decision**: Use latest stable AVM modules by repository reference (e.g., `avm/res/desktopvirtualization/hostpool`, `avm/res/desktopvirtualization/applicationgroup`, `avm/res/desktopvirtualization/workspace`, `avm/res/network/virtualNetwork`, `avm/res/compute/virtualMachine`). Pin module versions via Git tag or published version once identified during implementation.
- **Rationale**: AVM provides standardized, well-tested resource compositions reducing template complexity and improving maintainability.
- **Alternatives Considered**: Raw resource definitions (higher maintenance, more boilerplate); Terraform (would add tooling divergence and complexity).

### 2. Base Image Reference (Windows 11 Multi-Session)
- **Decision**: Use latest `Windows 11 Enterprise multi-session + Microsoft 365 Apps` base but exclude Office by customizing removal? REJECTED— simpler: choose `Windows 11 Enterprise multi-session` image offer without Office (to meet "No Office" requirement). Publisher: `MicrosoftWindowsDesktop`, Offer: `Windows-11`, Sku: `win11-22h2-ent-multi-session` (exact SKU to verify at deploy time).
- **Rationale**: Meets multi-session requirement while avoiding Office components, reducing image size and build time.
- **Alternatives**: Use image with Office pre-installed (violates requirement); Build from marketplace generic Windows 11 Pro (not multi-session capable).

### 3. VS Code Installation Method in Image Builder
- **Decision**: Use winget command in PowerShell customizer: `winget install -e --id Microsoft.VisualStudioCode` during image build.
- **Rationale**: Winget ensures latest stable release, simple command; avoids manual MSI download and version pin drift.
- **Alternatives**: Chocolatey (additional bootstrap), direct MSI (manual version management), Azure VM Extension post-deploy (slower first launch, inconsistent across hosts).

### 4. Registration Token Lifecycle Management
- **Decision**: Generate registration token via Bicep output and set expiration (e.g., 24h) for initial provisioning; subsequent scaling operations generate new token if expired.
- **Rationale**: Limits exposure of long-lived token; aligns with security minimization.
- **Alternatives**: Long-lived token (security risk), manual token generation (non-reproducible).

### 5. What-If Enforcement in CI
- **Decision**: Include manual step guidance in quickstart; automation TBD— mark as future enhancement (NOT BLOCKING). For Phase 1, document command: `az deployment sub what-if` with parameters referencing dev file.
- **Rationale**: Keeps PoC lightweight; avoids premature CI pipeline complexity.
- **Alternatives**: Mandatory pipeline gating (higher initial setup overhead), no validation (risk of unintended changes).

### 6. Load Balancing Strategy
- **Decision**: Breadth-first (maximize session distribution) to reduce resource contention early.
- **Rationale**: Better experience for concurrent dev users on limited hosts.
- **Alternatives**: Depth-first (could overload first host), persistent single-host (limits scalability demonstration).

### 7. Scaling Approach
- **Decision**: Simple parameter `hostCount` loop creating N session hosts from same image; no autoscale logic.
- **Rationale**: Satisfies user story 3 with minimal complexity; deterministic cost.
- **Alternatives**: VM Scale Set + autoscale rules (overkill for PoC), manual VM creation (less reproducible).

### 8. Image Version Tagging
- **Decision**: Tag managed image with `name + yyyyMMddHHmm` timestamp and output version.
- **Rationale**: Simple uniqueness; aids roll-forward identification.
- **Alternatives**: Semantic versioning (requires change management overhead), untagged (hard to distinguish builds).

### 9. VS Code Path for RemoteApp
- **Decision**: Publish app using path: `"C:\\Program Files\\Microsoft VS Code\\Code.exe"` (verify after image build; fallback check `AppData\Local` if system-wide install location differs).
- **Rationale**: Standard machine-level winget install path.
- **Alternatives**: User profile install (not suitable for multi-user baseline), script copy to custom directory (adds complexity).

### 10. Network Strategy
- **Decision**: Single VNet + single Subnet dedicated to session hosts; no NSG customization initial (default rules) documented as future enhancement.
- **Rationale**: Minimizes cost and complexity; meets connectivity requirements.
- **Alternatives**: Hub-spoke (excessive for PoC), multiple subnets (no added value now).

## Updated Clarification Status
All previously marked NEEDS CLARIFICATION items resolved except CI automation (intentionally deferred). No blockers for Phase 1 design.

## Research Impact Summary
- Adopt AVM modules to reduce template size and accelerate provisioning.
- Use winget-based VS Code install for currency.
- Timestamp-based image versioning ensures clarity without semantic overhead.
- security: Short-lived registration token reduces long-term exposure.

## Next Steps (Phase 1)
1. Data model translate entities → parameters mapping.
2. Contracts: parameters schema JSON + README.
3. Quickstart including image build then infra deploy sequence.
4. Update agent context with new technologies (AVM, Image Builder, winget).
