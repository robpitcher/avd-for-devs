<!--
  SYNC IMPACT REPORT
  Version: 0.0.0 → 1.0.0

  Modified Principles:
    - All principles newly defined (initial constitution)

  Added Sections:
    - Core Principles (I-V)
    - PoC-Specific Constraints
    - Quality & Compliance Standards
    - Governance

  Removed Sections:
    - None (initial version)

  Templates Requiring Updates:
    ✅ .specify/templates/plan-template.md - Constitution Check section aligns
    ✅ .specify/templates/spec-template.md - Requirements and edge cases align
    ✅ .specify/templates/tasks-template.md - Task categorization aligns

  Follow-up TODOs:
    - None
-->

# AVD for Devs Constitution

## Core Principles

### I. Cost Optimization (NON-NEGOTIABLE)

This project is a **proof of concept** demonstrating low-cost Azure Virtual Desktop development environments. Every architectural decision, resource selection, and configuration MUST prioritize cost efficiency while maintaining functional viability.

**Rules**:
- Default deployments MUST use minimum viable resource SKUs (e.g., D2s_v5 or B-series VMs)
- Default configuration MUST deploy single session host unless scaling explicitly requested
- Infrastructure MUST support start/stop automation to minimize compute costs during non-use
- No premium features (e.g., FSLogix, custom images, premium storage) unless justified by PoC requirements

**Rationale**: As a PoC, demonstrating value at minimal cost proves viability for broader adoption. Cost overruns undermine the core value proposition of "low-cost development environments."

### II. Infrastructure as Code (IaC) Discipline

All infrastructure MUST be defined, deployed, and versioned through Bicep templates. Manual Azure portal changes are prohibited except for troubleshooting/validation purposes and MUST be captured back into IaC.

**Rules**:
- Every Azure resource MUST be declared in Bicep modules under `src/infra/`
- Parameter files MUST separate environment-specific values from template logic
- Modules MUST be reusable and single-purpose (e.g., `hostpool.bicep`, `network.bicep`)
- Templates MUST pass `what-if` validation before deployment
- No orphaned resources: destruction of infrastructure MUST be reproducible via parameter changes or explicit teardown scripts

**Rationale**: IaC ensures repeatability, version control, and prevents configuration drift—critical for a PoC meant to be replicated across teams or environments.

### III. Specification-Driven Development

Features MUST be specified before implementation. Specifications define user stories, requirements, success criteria, and assumptions—serving as source of truth and preventing scope creep.

**Rules**:
- Every feature branch MUST have a corresponding spec in `/specs/[###-feature-name]/spec.md`
- Specifications MUST include: prioritized user stories (P1, P2, P3...), functional requirements (FR-###), success criteria (SC-###), and documented assumptions
- User stories MUST be independently testable—each story delivers standalone value
- Implementation MUST NOT begin until specification is approved
- Changes to requirements MUST update the specification file, not just code

**Rationale**: Specifications prevent miscommunication, enable parallelization (independent user stories), and provide clear success metrics for PoC validation.

### IV. Security Baseline

Security MUST meet Azure best practices for development environments without over-engineering. PoC status does NOT exempt security fundamentals.

**Rules**:
- Entra ID authentication MUST be used for all user access (no local accounts)
- Application group assignments MUST use Entra ID security groups, not individual user grants
- Session hosts MUST use managed identities for Azure service access (no stored credentials)
- Admin credentials MUST be parameterized and passed securely (ConvertTo-SecureString, Azure Key Vault, or deployment-time prompts)
- Network security groups MUST restrict inbound traffic to minimum required ports
- No public IP addresses on session hosts unless explicitly required and documented

**Rationale**: Security lapses in PoCs often carry forward into production. Establishing a secure baseline early prevents technical debt and demonstrates enterprise readiness.

### V. Clarity Over Cleverness

Code, documentation, and architecture MUST prioritize readability and maintainability. This PoC will be reviewed, forked, and adapted by others—complexity is a liability.

**Rules**:
- Bicep modules MUST have descriptive parameter names and inline comments for non-obvious logic
- README and quickstart guides MUST enable first-time users to deploy successfully within 30 minutes
- Scripts MUST include explanation comments and error messages that guide resolution
- Naming conventions MUST be consistent (e.g., `rg-avd-dev`, `avd-vm-000`) and self-documenting
- Avoid nesting beyond 3 levels in Bicep; extract complex logic into separate modules
- Document WHY, not just WHAT—especially for cost/security trade-offs

**Rationale**: PoCs are learning artifacts. If the code is inscrutable, the PoC fails to educate or enable replication.

## PoC-Specific Constraints

### Scope Limitations

The following are explicitly **OUT OF SCOPE** for this PoC to maintain cost discipline and focus:

- FSLogix profile containers (using default roaming profiles)
- Custom Azure Compute Gallery images (using marketplace Windows 11 multi-session + script-based installation)
- Azure Image Builder pipelines (superseded by custom script extension approach)
- Auto-scaling solutions (manual scaling via parameter adjustment only)
- Office 365 application installation
- Advanced monitoring/telemetry beyond Azure Monitor defaults
- Multi-region deployments (single region default: `canadacentral`)

**Changes to scope** (adding out-of-scope items) require:
1. Documented cost impact assessment
2. Justification against PoC goals
3. Specification amendment with new success criteria

### Technology Stack

- **IaC Language**: Bicep (Azure Resource Manager DSL)
- **Base Image**: Azure Marketplace Windows 11 Enterprise multi-session (latest)
- **Software Provisioning**: Custom Script Extension with PowerShell + winget
- **Authentication**: Entra ID (Azure Active Directory)
- **Published Application**: Visual Studio Code (single RemoteApp initially)
- **Deployment Tooling**: Azure PowerShell or Azure CLI
- **Validation**: PowerShell `what-if` scripts

Deviations from this stack MUST be justified and documented in the relevant specification.

## Quality & Compliance Standards

### Documentation Requirements

- Every specification MUST include measurable success criteria (SC-###)
- Every Bicep module MUST have parameter descriptions
- README MUST include: prerequisites, quickstart (≤ 30 min to deploy), cost estimates, scaling guidance
- Edge cases MUST be documented in specification (what happens when...)

### Deployment Validation

- All deployments MUST be validated with `what-if` before applying (`New-AzSubscriptionDeployment -WhatIf`)
- Deployment scripts MUST surface actionable error messages (not just stack traces)
- Default parameter files (`dev.bicepparam`) MUST represent a valid, deployable configuration

### User Acceptance

Each user story in a specification MUST define:
- **Independent Test**: How the story can be validated in isolation
- **Acceptance Scenarios**: Given/When/Then conditions for success
- **Priority**: P1 (MVP-critical), P2 (value-add), P3 (nice-to-have)

Implementation is NOT complete until acceptance scenarios pass.

## Governance

### Amendment Process

1. Proposed changes to this constitution MUST be documented via pull request with rationale
2. Changes affecting cost, security, or scope constraints require explicit justification
3. Version number MUST be updated following semantic versioning:
   - **MAJOR**: Removal of principles, incompatible constraint changes (e.g., removing cost optimization requirement)
   - **MINOR**: Addition of principles, new constraints, or materially expanded guidance
   - **PATCH**: Clarifications, wording improvements, typo fixes
4. All dependent templates (plan, spec, tasks) MUST be reviewed for alignment and updated if necessary

### Compliance Verification

- All specifications MUST reference applicable principles when documenting requirements or constraints
- Pull requests introducing new features MUST include a "Constitution Check" confirming alignment
- Cost-impacting changes MUST include updated cost estimates in documentation
- Security-impacting changes MUST document threat model considerations

### Conflict Resolution

- This constitution supersedes informal practices or undocumented conventions
- When requirements conflict with principles, principles take precedence unless amendment process is followed
- Complexity introduced in violation of Principle V (Clarity Over Cleverness) MUST be refactored or explicitly justified in technical debt log

**Version**: 1.0.0 | **Ratified**: 2025-11-17 | **Last Amended**: 2025-11-17
