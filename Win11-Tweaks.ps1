<# 
  Windows 11 privacy & declutter tweaks
  Save as: Win11-Tweaks.ps1
  Run normally; script will self-elevate if needed.
#>
$ErrorActionPreference = 'Stop'
#-----------------------------#
# Self-elevate if needed      #
#-----------------------------#
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Requesting administrator rights..." -ForegroundColor Yellow

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName  = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb      = "runas"

    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Warning "Elevation was declined. Script cannot continue."
    }

    exit
}

Write-Host "Applying Windows 11 tweaks..." -ForegroundColor Cyan

#-----------------------------#
# 1. Advertising ID & offers  #
#-----------------------------#

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "PrivacyExperienceCompleted" -Type DWord -Value 1

New-Item -Path "HKCU:\Control Panel\International\User Profile" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1

Write-Host "Advertising ID and recommendation-related settings adjusted." -ForegroundColor Green

#-----------------------------#
# 2. Disable Bing web search  #
#-----------------------------#

$explorerPolicyKey = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
New-Item -Path $explorerPolicyKey -Force | Out-Null

Set-ItemProperty -Path $explorerPolicyKey -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
Set-ItemProperty -Path $explorerPolicyKey -Name "DisableWebSearch" -Type DWord -Value 1

Write-Host "Start menu web/Bing search disabled." -ForegroundColor Green

#-----------------------------#
# 3. Widgets off              #
#-----------------------------#

$dshKey = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
New-Item -Path $dshKey -Force | Out-Null
Set-ItemProperty -Path $dshKey -Name "AllowNewsAndInterests" -Type DWord -Value 0

Write-Host "Widgets disabled (policy)." -ForegroundColor Green


#-----------------------------#
# 4. Start menu Recommended   #
#-----------------------------#

Set-ItemProperty -Path $advKey -Name "Start_TrackProgs" -Type DWord -Value 0
Set-ItemProperty -Path $advKey -Name "Start_TrackDocs" -Type DWord -Value 0

$cdmKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
New-Item -Path $cdmKey -Force | Out-Null
Set-ItemProperty -Path $cdmKey -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0

Write-Host "Start menu recommendations reduced." -ForegroundColor Green

#-----------------------------#
# 5. Diagnostic & typing data #
#-----------------------------#

$dataCollKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
New-Item -Path $dataCollKey -Force | Out-Null
Set-ItemProperty -Path $dataCollKey -Name "AllowTelemetry" -Type DWord -Value 1

$tipcKey = "HKCU:\Software\Microsoft\Input\TIPC"
New-Item -Path $tipcKey -Force | Out-Null
Set-ItemProperty -Path $tipcKey -Name "Enabled" -Type DWord -Value 0

Write-Host "Diagnostic and input-related data collection reduced." -ForegroundColor Green

#-----------------------------#
# 6. Lock screen & promos     #
#-----------------------------#

$lockKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
New-Item -Path $lockKey -Force | Out-Null

Set-ItemProperty -Path $lockKey -Name "CreativeLockScreenSource" -Type DWord -Value 1

Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0

Write-Host "Lock screen ads and promos disabled." -ForegroundColor Green

#-----------------------------#
# 7. System tips & suggestions#
#-----------------------------#

Set-ItemProperty -Path $cdmKey -Name "SoftLandingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0

Write-Host "System tips and suggestion notifications disabled." -ForegroundColor Green

#-----------------------------#
# 8. Explorer sync nudges     #
#-----------------------------#

Set-ItemProperty -Path $advKey -Name "ShowSyncProviderNotifications" -Type DWord -Value 0

Write-Host "File Explorer sync provider notifications disabled." -ForegroundColor Green

#-----------------------------#
# 9. Finish                   #
#-----------------------------#

Write-Host "`nAll tweaks applied. A sign-out or reboot is recommended for everything to fully take effect." -ForegroundColor Cyan
