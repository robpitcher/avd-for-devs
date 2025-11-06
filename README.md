# AVD for Devs

Infrastructure as Code (IaC) scaffolding for experimenting with Azure Virtual Desktop (AVD) resources using Bicep at subscription scope.

## 📋 Prerequisites

Ensure the following are installed/configured:

1. Docker Desktop (for Dev Container experience) – running
2. VS Code with Dev Containers extension (or GitHub Codespaces)
3. Azure PowerShell module (Az) or Azure CLI
4. Access to an Azure subscription with permission to deploy at subscription scope (e.g. Owner or Contributor + Resource Group write)

## Quickstart

1. Copy `example.bicepparam` to `main.bicepparam` and update parameter values as desired for your environment.

2. Login before deploying:

```powershell
Connect-AzAccount
```

3. If you have multiple subscriptions:

```powershell
Set-AzContext -Subscription <your-subscription-id-or-name>
```

4. Run the deployment
```powershell
New-AzSubscriptionDeployment -Location eastus -Name "avd-deploy" -TemplateFile .\src\infra\main.bicep -TemplateParameterFile .\src\infra\main.bicepparam
```