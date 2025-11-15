#Requires -Version 7.0

<#
.SYNOPSIS
    Validates Azure deployment using what-if command.

.DESCRIPTION
    Runs Azure deployment what-if to preview changes before actual deployment.
    Helps identify potential issues and validate template changes.

.PARAMETER TemplateFile
    Path to the main Bicep template file.

.PARAMETER ParameterFile
    Path to the parameter file.

.PARAMETER Location
    Azure location for subscription-level deployment.

.PARAMETER DeploymentName
    Name for the deployment.

.EXAMPLE
    .\validate-whatif.ps1 -TemplateFile .\src\infra\main.bicep -ParameterFile .\src\infra\parameters\dev.bicepparam -Location canadacentral

.NOTES
    Author: AVD Dev Environment
    Date: 2025-11-15
    Requires: Azure PowerShell module (Az)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TemplateFile,

    [Parameter(Mandatory = $true)]
    [string]$ParameterFile,

    [Parameter(Mandatory = $false)]
    [string]$Location = 'canadacentral',

    [Parameter(Mandatory = $false)]
    [string]$DeploymentName = "avd-whatif-$(Get-Date -Format 'yyyyMMddHHmmss')"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $color = switch ($Level) {
        'ERROR' { 'Red' }
        'WARN' { 'Yellow' }
        'SUCCESS' { 'Green' }
        default { 'White' }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

try {
    Write-Log "Starting Azure deployment what-if validation" -Level 'INFO'

    # Verify files exist
    if (-not (Test-Path $TemplateFile)) {
        throw "Template file not found: $TemplateFile"
    }

    if (-not (Test-Path $ParameterFile)) {
        throw "Parameter file not found: $ParameterFile"
    }

    Write-Log "Template file: $TemplateFile"
    Write-Log "Parameter file: $ParameterFile"
    Write-Log "Location: $Location"
    Write-Log "Deployment name: $DeploymentName"

    # Check Azure PowerShell module
    if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
        throw "Azure PowerShell module (Az.Resources) is not installed. Install with: Install-Module -Name Az -Scope CurrentUser"
    }

    # Check Azure context
    Write-Log "Checking Azure context..."
    $context = Get-AzContext
    if (-not $context) {
        throw "Not logged in to Azure. Run 'Connect-AzAccount' first."
    }

    Write-Log "Subscription: $($context.Subscription.Name) ($($context.Subscription.Id))"
    Write-Log "Account: $($context.Account.Id)"

    # Run what-if
    Write-Log "Running deployment what-if (this may take a few minutes)..." -Level 'INFO'

    $whatIfParams = @{
        Location         = $Location
        Name             = $DeploymentName
        TemplateFile     = $TemplateFile
        TemplateParameterFile = $ParameterFile
    }

    $result = New-AzSubscriptionDeployment @whatIfParams -WhatIf

    Write-Log "What-if validation completed successfully!" -Level 'SUCCESS'
    Write-Log "Review the output above to see what changes would be made."

    exit 0

} catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level 'ERROR'
    if ($_.ScriptStackTrace) {
        Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level 'ERROR'
    }
    exit 1
}
