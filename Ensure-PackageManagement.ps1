# iwr "https://github.com/philmorinca/Powershell/raw/refs/heads/main/Ensure-PackageManagement.ps1" -UseBasicParsing | iex
# URL of the package
$Url = "https://cdn.powershellgallery.com/packages/packagemanagement.1.4.8.1.nupkg"

# Where to download the file
$DownloadPath = "$env:TEMP\packagemanagement.1.4.8.1.nupkg"
$ZipPath = "$DownloadPath.zip"
# Module installation directory
$ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.8.1"

# Create module directory if missing
if (!(Test-Path $ModulePath)) {
    New-Item -ItemType Directory -Path $ModulePath -Force | Out-Null
}

# Download the package
Invoke-WebRequest -Uri $Url -OutFile $DownloadPath
Move-Item $DownloadPath $ZipPath
# Extract the .nupkg (it's a ZIP file)
Expand-Archive -Path $ZipPath -DestinationPath $ModulePath -Force

# Remove the downloaded file
Remove-Item $ZipPath -Force

# Update module cache
$null = Get-Module -ListAvailable | Out-Null

Set-ExecutionPolicy Bypass -Scope Process

Import-Module PackageManagement
# Installer NuGet sans interaction
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Installer PowerShellGet et PackageManagement
Install-Module PowerShellGet -Force

