$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process -Force

Remove-Item "C:\setupcomplete.cmd" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Win10LTSC.iso" -Force -ErrorAction SilentlyContinue

#Activate windows
& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID

## Helper function to ensure registry path exists
function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# Define app patterns to remove
$appPatterns = @(
    "*LinkedIn*",
    "*Skype*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.XboxApp*",
    "*Microsoft.XboxGameOverlay*",
    "*Microsoft.XboxGamingOverlay*",
    "*Microsoft.XboxSpeechToTextOverlay*",
    "*Microsoft.XboxIdentityProvider*",
    "*Microsoft.Xbox.TCUI*",
    "*Microsoft.MinecraftUWP*"
)

foreach ($pattern in $appPatterns) {
    Write-Host "Searching for: $pattern"

    # Remove installed packages for current user
    $installed = Get-AppxPackage | Where-Object { $_.Name -like $pattern }
    foreach ($pkg in $installed) {
        Write-Host "Removing installed package: $($pkg.Name)"
        Remove-AppxPackage -Package $pkg.PackageFullName
    }

    # Remove provisioned packages (for new users)
    $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $pattern }
    foreach ($prov in $provisioned) {
        Write-Host "Removing provisioned package: $($prov.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName
    }
}

# Disable Cortana
Ensure-RegistryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -Force

# Disable Task View button
Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord

# Disable Search box
Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

# Disable People icon
Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Value 0 -Type DWord

# Disable Windows Ink Workspace
Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Value 0 -Type DWord

# Disable Touch Keyboard button
Ensure-RegistryPath "HKCU:\Software\Microsoft\TabletTip\1.7"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "EnableDesktopModeAutoInvoke" -Value 0 -Type DWord

# Fully disable News and Interests feature
Ensure-RegistryPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0 -Type DWord -Force

# Hide Meet Now button
Ensure-RegistryPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 1 -Type DWord

# Restart Explorer to apply changes
Stop-Process -Name explorer -Force
Start-Process explorer
