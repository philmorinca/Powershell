#  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; iwr "https://raw.githubusercontent.com/philmorinca/Powershell/refs/heads/main/Ensure-SqlServer-Module.ps1?t=$(Get-Date -UFormat %s)" -UseBasicParsing | iex
#  
# Ensure TLS 1.2 for PSGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process

if ( -not (Get-Command "Install-PackageProvider" -ErrorAction SilentlyContinue))
{
    iwr "https://raw.githubusercontent.com/philmorinca/Powershell/refs/heads/main/Ensure-PackageManagement.ps1?t=$(Get-Date -UFormat %s)" -UseBasicParsing | iex
}

Get-Item  "C:\Program File*\Microsoft SQL Server\*\Tools\PowerShell\Modules\sqlps" | Remove-Item -Recurse -Force

# Install module silently
Install-Module -Name SqlServer -Force -AcceptLicense
