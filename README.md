# AVD for Devs - Azure Virtual Desktop Development Environment

Infrastructure as Code (IaC) for deploying a low-cost Azure Virtual Desktop (AVD) environment with Visual Studio Code RemoteApp for development teams.

## 🎯 Features

- **VS Code RemoteApp**: Pre-configured Visual Studio Code published as RemoteApp
- **Custom Image**: Windows 11 Enterprise multi-session with VS Code pre-installed via Azure Image Builder
- **Group-Based Access**: Entra ID group assignment for secure, managed access
- **Manual Scaling**: Parameter-driven scaling (adjust `hostCount` to scale up/down)
- **Cost-Optimized**: Single D2s_v5 session host by default; pay-as-you-go model

## 📋 Prerequisites

1. **Azure Subscription**: Contributor or Owner role at subscription scope
2. **Azure PowerShell** or **Azure CLI** installed locally
3. **Entra ID Security Group**: Create a group for developers who should access the environment
4. **Docker Desktop** (optional, for Dev Container experience)
5. **VS Code with Dev Containers extension** (optional)

## 🚀 Quickstart

### Step 1: Prepare Parameters

1. Copy the example parameter file:
   ```powershell
   Copy-Item .\src\infra\parameters\example.bicepparam .\src\infra\parameters\dev.bicepparam
   ```

2. Edit `dev.bicepparam`:
   - Set `entraIdGroupObjectId` to your security group's Object ID
   - Update `adminPassword` (will prompt during deployment for security)
   - Adjust `location` if needed (default: `canadacentral`)

### Step 2: Login to Azure

```powershell
Connect-AzAccount
Set-AzContext -Subscription <your-subscription-id-or-name>
```

### Step 3: Deploy Infrastructure

```powershell
New-AzSubscriptionDeployment `
  -Location canadacentral `
  -Name "avd-deploy-$(Get-Date -Format 'yyyyMMddHHmm')" `
  -TemplateFile .\src\infra\main.bicep `
  -TemplateParameterFile .\src\infra\parameters\dev.bicepparam
```

**Deployment Time**: ~15-20 minutes (including session host provisioning)

### Step 4: Access VS Code RemoteApp

1. Users in the assigned Entra ID group can access via:
   - **Windows AVD Client**: Download from [aka.ms/wvdclient](https://aka.ms/wvdclient)
   - **Web Client**: [rdweb.wvd.microsoft.com](https://rdweb.wvd.microsoft.com)

2. Sign in with Entra ID credentials
3. Launch "Visual Studio Code" RemoteApp

## 💰 Cost Guidance

### Monthly Cost Estimate (Single Session Host)

**Assumptions**:
- 1 session host: `Standard_D2s_v5` (2 vCPU, 8 GB RAM)
- Region: Canada Central
- Usage: 8 hours/day, 22 business days/month = 176 hours/month
- Stopped when not in use (manual or via automation)

| Resource | Unit Cost (approx.) | Monthly Cost |
|----------|---------------------|--------------|
| Session Host VM (D2s_v5) | $0.096/hour | $16.90 (176h) |
| OS Disk (128 GB Premium SSD) | $19.71/month | $19.71 |
| Virtual Network | Free (egress minimal) | $0.00 |
| AVD Control Plane | Free | $0.00 |
| **Total (1 host, part-time)** | | **~$37/month** |

**Full-Time (730 hours/month)**: ~$90/month
**Additional Hosts**: Add ~$37/month per host (part-time) or ~$90/month (full-time)

### Cost Optimization Tips

1. **Stop VMs when not in use**:
   ```powershell
   Stop-AzVM -ResourceGroupName rg-avd-dev -Name avd-vm-000 -Force
   ```

2. **Use B-series burstable VMs** for non-intensive workloads (e.g., `Standard_B2ms`): ~$12/month (part-time)

3. **Leverage Azure Reservations**: 1-year reserved instance saves ~40%

4. **Delete test environments** when not actively developing

### Scaling Impact on Cost

- **2 Hosts**: ~$74/month (part-time), ~$180/month (full-time)
- **3 Hosts**: ~$111/month (part-time), ~$270/month (full-time)

**Recommendation**: Start with 1 host; scale up based on actual concurrent user demand (see `docs/scaling-down.md`).

## 📚 Documentation

- **[Quickstart Guide](specs/001-avd-dev-vscode/quickstart.md)**: Detailed deployment and usage instructions
- **[Outputs Documentation](docs/outputs.md)**: Understanding deployment outputs (host pool ID, registration token, etc.)
- **[Scaling Down Procedure](docs/scaling-down.md)**: How to gracefully reduce session host count
- **[Security Checklist](docs/security-checklist.md)**: Security review and hardening recommendations
- **[Test Plans](tests/)**: Validation procedures for RemoteApp, image build, and scaling

## 🧪 Testing & Validation

Manual test plans are provided for each user story:
- **US1**: [RemoteApp Validation](tests/US1-remoteapp-validation.md) - Launch time, access control
- **US2**: [Image Build Checklist](tests/US2-image-build-checklist.md) - Custom image validation
- **US3**: [Scaling Validation](tests/US3-scaling-validation.md) - Scale up/down procedures

Run validations after deployment to ensure all success criteria are met.

## 🛠️ Scaling Operations

### Scale Up
1. Edit `dev.bicepparam`: Increase `hostCount` (e.g., from 1 to 2)
2. Redeploy (same command as initial deployment)
3. New session host(s) will provision and register automatically

### Scale Down
See [Scaling Down Procedure](docs/scaling-down.md) for graceful drain and removal steps.

## 🔒 Security Highlights

- **Entra ID Authentication**: Native Azure AD integration, MFA support
- **Group-Based Access Control**: Only authorized users can see/launch RemoteApp
- **Short-Lived Registration Tokens**: 24-hour expiration (configurable)
- **Secure Parameters**: Admin passwords use `@secure()` annotation
- **No Public IPs** (recommended): Configure NSG rules for production

Full security review: [docs/security-checklist.md](docs/security-checklist.md)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Entra ID                                               │
│  ├── Security Group (Developers)                       │
│  └── User Authentication                               │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  AVD Workspace (dev-avd-ws)                            │
│  └── Application Group (RemoteApp)                     │
│      └── VS Code RemoteApp                             │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Host Pool (dev-avd-hostpool)                          │
│  ├── Load Balancing: BreadthFirst                      │
│  └── Max Sessions: 10 per host                         │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Virtual Network (dev-avd-vnet)                        │
│  └── Subnet (dev-avd-subnet)                           │
│      ├── Session Host VM 1 (avd-vm-000)                │
│      ├── Session Host VM 2 (avd-vm-001) [if scaled]    │
│      └── ...                                            │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│  Custom Image (optional)                               │
│  └── Windows 11 Enterprise multi-session + VS Code     │
└─────────────────────────────────────────────────────────┘
```

## 🧩 Project Structure

```
avd-for-devs/
├── src/infra/                  # Infrastructure as Code
│   ├── main.bicep              # Main template (subscription scope)
│   ├── modules/                # Bicep modules
│   │   ├── network.bicep       # VNet and subnet
│   │   ├── hostpool.bicep      # AVD host pool
│   │   ├── workspace.bicep     # AVD workspace
│   │   ├── appGroup.bicep      # Application group
│   │   ├── remoteApp.bicep     # RemoteApp publishing
│   │   ├── sessionHostVM.bicep # Session host VMs
│   │   ├── image-builder.bicep # Custom image (optional)
│   │   └── role-assignment.bicep # Access control
│   ├── parameters/             # Parameter files
│   │   └── dev.bicepparam      # Development environment
│   └── scripts/                # Customization scripts
│       └── install-vscode.ps1  # VS Code winget installer
├── docs/                       # Documentation
│   ├── outputs.md              # Deployment outputs guide
│   ├── scaling-down.md         # Scale-down procedures
│   └── security-checklist.md   # Security review
├── tests/                      # Manual test plans
│   ├── US1-remoteapp-validation.md
│   ├── US2-image-build-checklist.md
│   ├── US3-scaling-validation.md
│   └── success-criteria-report.md
├── scripts/                    # Automation scripts
│   └── validate-whatif.ps1     # What-if validation
└── specs/                      # Feature specifications
    └── 001-avd-dev-vscode/     # Current feature
```

## 🤝 Contributing

This is a proof-of-concept project for AVD experimentation. Contributions welcome:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

See [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Azure AVD Documentation**: [Microsoft Learn - AVD](https://learn.microsoft.com/azure/virtual-desktop/)

## 🎓 Learning Resources

- [Azure Virtual Desktop Documentation](https://learn.microsoft.com/azure/virtual-desktop/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [AVD Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

---

**Last Updated**: 2025-11-15
**Maintained By**: AVD for Devs Project