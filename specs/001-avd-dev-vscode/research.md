# Phase 0 Research: Azure Virtual Desktop Dev Environment (VS Code Published App)

**Date**: 2025-11-15
**Feature**: `specs/001-avd-dev-vscode/spec.md`
**Updated**: 2025-11-16 (Reflects marketplace image + script extension implementation)

## Clarifications & Decisions

### 1. Module Implementation Approach
- **Decision**: Use custom Bicep modules (not AVM) for full control and simplicity in this PoC environment. Modules implemented: network, hostpool, workspace, appGroup, workspace-association, remoteApp, sessionHostVM, role-assignment.
- **Rationale**: Custom modules provide complete flexibility for this specific use case without external dependencies. Simpler for learning and customization in a development environment.
- **Alternatives Considered**: AVM modules (adds complexity and external dependencies for PoC); raw resource definitions (less maintainable).

### 2. Base Image Reference (Windows 11 Multi-Session)
- **Decision**: Use marketplace `Windows 11 Enterprise multi-session` image without Office. Publisher: `MicrosoftWindowsDesktop`, Offer: `Windows-11`, SKU: `win11-22h2-ent-multi-session`, Version: `latest`.
- **Rationale**: Meets multi-session requirement while avoiding Office components. Always uses latest patched version from marketplace. No custom image build required.
- **Alternatives**: Custom image with Image Builder (adds complexity, slower deployments); Image with Office pre-installed (violates "No Office" requirement).

### 3. VS Code Installation Method via Custom Script Extension
- **Decision**: Install VS Code during VM provisioning using custom script extension that executes PowerShell script with winget command: `winget install --exact --id Microsoft.VisualStudioCode --silent --scope machine`.
- **Rationale**: Simple, repeatable, always installs latest VS Code version. Script execution is logged and deployment fails if installation fails. No pre-built custom image needed. Faster deployment cycle than Image Builder.
- **Alternatives**: Azure Image Builder (overkill for single app, slower); Chocolatey (additional bootstrap needed); Direct MSI download (manual version management).

### 4. Registration Token Lifecycle Management
- **Decision**: Generate registration token via Bicep output and set expiration (default 24h) for initial provisioning; subsequent scaling operations use existing token if valid.
- **Rationale**: Limits exposure of long-lived token; aligns with security minimization.
- **Alternatives**: Long-lived token (security risk), manual token generation (non-reproducible).

### 5. What-If Enforcement in CI
- **Decision**: Include manual step guidance in quickstart; automation marked as future enhancement. Document `az deployment sub what-if` command for validation.
- **Rationale**: Keeps PoC lightweight; avoids premature CI pipeline complexity.
- **Alternatives**: Mandatory pipeline gating (higher initial setup overhead), no validation (risk of unintended changes).

### 6. Load Balancing Strategy
- **Decision**: Breadth-first (maximize session distribution) to reduce resource contention across hosts.
- **Rationale**: Better experience for concurrent dev users on limited hosts.
- **Alternatives**: Depth-first (could overload first host).

### 7. Scaling Approach
- **Decision**: Simple parameter `hostCount` loop creating N session hosts; no autoscale logic. Each VM provisions from marketplace image and runs custom script extension.
- **Rationale**: Satisfies user story 3 with minimal complexity; deterministic cost. Script extension ensures consistent VS Code installation across all hosts.
- **Alternatives**: VM Scale Set + autoscale rules (overkill for PoC), manual VM creation (less reproducible).

### 8. Custom Script Extension Configuration
- **Decision**: VM custom script extension downloads install-vscode.ps1 from GitHub repository (or configurable URI) and executes during VM provisioning. Extension runs after VM join to host pool.
- **Rationale**: Clean separation of infrastructure provisioning and software installation. Script can be updated without changing Bicep code. Clear success/failure status.
- **Alternatives**: VM initialization scripts (less visible status), manual post-deployment (inconsistent).

### 9. VS Code Path for RemoteApp
- **Decision**: Publish app using path: `C:\\Program Files\\Microsoft VS Code\\Code.exe`. Script verifies installation at this location.
- **Rationale**: Standard machine-level winget install path. Script includes verification and fallback search.
- **Alternatives**: User profile install (not suitable for multi-user), custom directory (adds complexity).

### 10. Network Strategy
- **Decision**: Single VNet + single Subnet dedicated to session hosts; no NSG customization (default rules). Resources deployed to dedicated resource group.
- **Rationale**: Minimizes cost and complexity; meets connectivity requirements.
- **Alternatives**: Hub-spoke (excessive for PoC), multiple subnets (no added value now).

## Updated Clarification Status
All clarification items resolved. Implementation uses marketplace images with custom script extension instead of Azure Image Builder. No blockers for deployment.

## Research Impact Summary
- Marketplace image approach eliminates custom image build complexity and reduces deployment time.
- Custom script extension provides flexible, updatable software installation process.
- Script-based VS Code installation ensures latest version without manual image updates.
- Registration token with 24-hour expiration reduces security exposure.
- Simple parameter-driven scaling (hostCount) enables manual capacity management.

## Architecture Benefits
- **Faster Deployments**: No image build phase (10-15 minutes vs 20-30 minutes)
- **Always Current**: Marketplace images receive automatic security patches from Microsoft
- **Simpler Maintenance**: Update installation script without rebuilding images
- **Clear Status**: Custom script extension provides explicit success/failure feedback
- **Cost Efficient**: No storage cost for custom images

## Next Steps (Phase 1)
1. Data model reflects marketplace image + script extension parameters.
2. Contracts: parameters schema JSON + README (completed).
3. Quickstart reflects direct deployment without image build phase.
4. Documentation updated to remove Image Builder references.
