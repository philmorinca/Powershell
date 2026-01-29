#  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; iwr https://github.com/philmorinca/Powershell/raw/refs/heads/main/Ensure-SqlServer-Module.ps1 -UseBasicParsing | iex
#  
# Ensure TLS 1.2 for PSGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# ------------------------------------------------------------
#  Auto‑fix PowerShellGet / NuGet provider (no prompts)
#  Compatible Windows PowerShell 5.1 + PowerShell 7+
# ------------------------------------------------------------

Write-Host "=== Vérification de la version PowerShell ==="

$IsPSCore = $PSVersionTable.PSEdition -eq "Core"

if ($IsPSCore) {
    Write-Host "PowerShell 7 détecté. Configuration via Windows PowerShell 5.1 requise."

    # Trouver Windows PowerShell 5.1
    $pwsh51 = (Get-Command powershell.exe).Source

    if (-not (Test-Path $pwsh51)) {
        Write-Host "Impossible de trouver Windows PowerShell 5.1. Abandon."
        exit 1
    }

    Write-Host "Lancement de Windows PowerShell 5.1 pour installer NuGet..."

    Start-Process $pwsh51 -Verb RunAs -ArgumentList @"
-NoProfile -ExecutionPolicy Bypass -Command "
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force;
Install-Module PowerShellGet -Force;
Install-Module PackageManagement -Force;
"
"@

    Write-Host "Configuration terminée. Redémarre PowerShell 7."
    exit
}

# ------------------------------------------------------------
#  Windows PowerShell 5.1 — installation silencieuse
# ------------------------------------------------------------

Write-Host "Windows PowerShell 5.1 détecté. Installation silencieuse du provider NuGet..."

# Installer NuGet sans interaction
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Installer PowerShellGet et PackageManagement
Install-Module PowerShellGet -Force
Install-Module PackageManagement -Force

# Rendre PSGallery de confiance
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Host "=== Configuration terminée ==="
Write-Host "NuGet installé, PSGallery approuvé, aucune invite ne réapparaîtra."


# Install NuGet provider silently
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Get-Item  "C:\Program File*\Microsoft SQL Server\*\Tools\PowerShell\Modules\sqlps" | Remove-Item -Recurse -Force


# Install module silently
Install-Module -Name SqlServer -Force -AcceptLicense
