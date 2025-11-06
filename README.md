# AVD for Devs

Infrastructure as Code (IaC) scaffolding for experimenting with Azure Virtual Desktop (AVD) resources using Bicep at subscription scope.

```powershell
New-AzSubscriptionDeployment -Location eastus -Name "avd-deploy" -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\src\infra\main.bicepparam
```

---

## 📋 Prerequisites

Ensure the following are installed/configured:

1. Docker Desktop (for Dev Container experience) – running
2. VS Code with Dev Containers extension (or GitHub Codespaces)
3. Azure PowerShell module (Az) or Azure CLI
4. Access to an Azure subscription with permission to deploy at subscription scope (e.g. Owner or Contributor + Resource Group write)

Login before deploying:

```powershell
Connect-AzAccount
```

If you have multiple subscriptions:

```powershell
Set-AzContext -Subscription <your-subscription-id-or-name>
```

Run the deployment
```powershell
New-AzSubscriptionDeployment -Location eastus -Name "avd-deploy" -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\src\infra\main.bicepparam
```