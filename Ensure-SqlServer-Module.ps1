# Ensure TLS 1.2 for PSGallery
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Trust PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install NuGet provider silently
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Get-Item  "C:\Program File*\Microsoft SQL Server\*\Tools\PowerShell\Modules\sqlps" | Remove-Item -Recurse -Force


# Install module silently
Install-Module -Name SqlServer -Force -AcceptLicense
