# iwr "https://raw.githubusercontent.com/philmorinca/Powershell/refs/heads/main/Win11-Tweaks.ps1?t=$(Get-Date -UFormat %s)" -UseBasicParsing | iex
<# 
  Windows 11 privacy & declutter tweaks
  Save as: Win11-Tweaks.ps1
  Run normally; script will self-elevate if needed.
#>
$ErrorActionPreference = 'Stop'
# URL of the script (update if you rename it)
$ScriptURL = "https://raw.githubusercontent.com/philmorinca/Powershell/refs/heads/main/Win11-Tweaks.ps1?t=$(Get-Date -UFormat %s)"

# Self-elevate if needed
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Requesting administrator rights..." -ForegroundColor Yellow

    $cmd = "iwr `"$ScriptURL`" -UseBasicParsing | iex; pause"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName  = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command $cmd"
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
