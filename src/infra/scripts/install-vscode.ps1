#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Installs Visual Studio Code using winget for AVD custom image.

.DESCRIPTION
    This script is designed to run during Azure Image Builder customization.
    It installs VS Code system-wide using winget package manager.

.NOTES
    Author: AVD Dev Environment
    Date: 2025-11-15
    Requires: Windows 11 with winget pre-installed
#>

[CmdletBinding()]
param(
    [string]$WingetId = 'Microsoft.VisualStudioCode'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Starting VS Code installation via winget"
    Write-Log "Winget Package ID: $WingetId"

    # Check if winget is available
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetPath) {
        throw "winget is not available. Ensure Windows App Installer is installed."
    }

    Write-Log "Winget found at: $($wingetPath.Source)"

    # Accept source agreements (non-interactive)
    Write-Log "Accepting winget source agreements"
    & winget source update --disable-interactivity | Out-Null

    # Install VS Code with system-wide scope
    Write-Log "Installing VS Code (this may take a few minutes)..."
    $installArgs = @(
        'install'
        '--exact'
        '--id', $WingetId
        '--silent'
        '--accept-package-agreements'
        '--accept-source-agreements'
        '--scope', 'machine'
    )

    $process = Start-Process -FilePath 'winget' -ArgumentList $installArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0) {
        throw "Winget install failed with exit code: $($process.ExitCode)"
    }

    Write-Log "VS Code installation completed successfully"

    # Verify installation
    $vscodePath = 'C:\Program Files\Microsoft VS Code\Code.exe'
    if (Test-Path $vscodePath) {
        Write-Log "Verified VS Code installed at: $vscodePath"

        # Get version
        $vscodeVersion = (& $vscodePath --version 2>$null | Select-Object -First 1)
        if ($vscodeVersion) {
            Write-Log "VS Code version: $vscodeVersion"
        }
    } else {
        Write-Log "Warning: VS Code executable not found at expected path: $vscodePath" -Level 'WARN'
        Write-Log "Searching for VS Code installation..." -Level 'WARN'

        # Search common locations
        $searchPaths = @(
            "${env:ProgramFiles}\Microsoft VS Code\Code.exe",
            "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe",
            "${env:LocalAppData}\Programs\Microsoft VS Code\Code.exe"
        )

        foreach ($path in $searchPaths) {
            if (Test-Path $path) {
                Write-Log "Found VS Code at: $path" -Level 'WARN'
            }
        }
    }

    Write-Log "Installation script completed successfully"
    exit 0

} catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level 'ERROR'
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level 'ERROR'
    exit 1
}
