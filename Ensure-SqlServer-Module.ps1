#  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; iwr https://github.com/philmorinca/Powershell/raw/refs/heads/main/Ensure-SqlServer-Module.ps1 -UseBasicParsing | iex
#  
# Ensure TLS 1.2 for PSGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
if ( -not (Get-Command "Install-PackageProvider"))
{
    
}
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
