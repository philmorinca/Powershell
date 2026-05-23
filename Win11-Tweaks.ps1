# iwr "https://github.com/philmorinca/Powershell/raw/refs/heads/main/Win11-Tweaks.ps1" -UseBasicParsing | iex
<# 
  Windows 11 privacy & declutter tweaks
  Based on MUO article: "I turned off these Windows 11 features that ship on by default…"

  Save as: Win11-Tweaks.ps1
  Run in elevated PowerShell (Run as administrator).
#>

#-----------------------------#
# Helper: Require elevation   #
#-----------------------------#
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    break
}

Write-Host "Applying Windows 11 tweaks..." -ForegroundColor Cyan

#-------------------------------------------#
# 1. Advertising ID & recommendations      #
#-------------------------------------------#

# Disable Advertising ID
# HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

# Disable personalized offers & recommendations (general privacy toggles)
# HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "PrivacyExperienceCompleted" -Type DWord -Value 1

# Disable “Allow websites to access my language list”
# HKCU\Control Panel\International\User Profile
New-Item -Path "HKCU:\Control Panel\International\User Profile" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1

Write-Host "Advertising ID and recommendation-related settings adjusted." -ForegroundColor Green

#-------------------------------------------#
# 2. Disable Bing web search in Start      #
#-------------------------------------------#

# HKCU\Software\Policies\Microsoft\Windows\Explorer
$explorerPolicyKey = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
New-Item -Path $explorerPolicyKey -Force | Out-Null

# Disable web search & Bing in Start
Set-ItemProperty -Path $explorerPolicyKey -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
Set-ItemProperty -Path $explorerPolicyKey -Name "DisableWebSearch" -Type DWord -Value 1

Write-Host "Start menu web/Bing search disabled." -ForegroundColor Green

#-------------------------------------------#
# 3. Disable Widgets (taskbar & backend)   #
#-------------------------------------------#

# Hide Widgets button on taskbar
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
$advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-Item -Path $advKey -Force | Out-Null
Set-ItemProperty -Path $advKey -Name "TaskbarDa" -Type DWord -Value 0

# Policy-level disable Widgets (News & Interests style)
# HKLM\SOFTWARE\Policies\Microsoft\Dsh  AllowNewsAndInterests = 0
$dshKey = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
New-Item -Path $dshKey -Force | Out-Null
Set-ItemProperty -Path $dshKey -Name "AllowNewsAndInterests" -Type DWord -Value 0

Write-Host "Widgets disabled (taskbar + policy)." -ForegroundColor Green

#-------------------------------------------#
# 4. Start menu “Recommended” section      #
#-------------------------------------------#

# These map to:
# - Show recently added apps
# - Show recently opened items in Start, Jump Lists, File Explorer
# - Show suggestions for tips, shortcuts, new apps, etc.

# Recently added apps
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced  Start_TrackProgs = 0
Set-ItemProperty -Path $advKey -Name "Start_TrackProgs" -Type DWord -Value 0

# Recently opened items
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced  Start_TrackDocs = 0
Set-ItemProperty -Path $advKey -Name "Start_TrackDocs" -Type DWord -Value 0

# Suggestions in Start
# HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager
$cdmKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
New-Item -Path $cdmKey -Force | Out-Null
Set-ItemProperty -Path $cdmKey -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0

Write-Host "Start menu recommendations reduced." -ForegroundColor Green

#-------------------------------------------#
# 5. Diagnostic data & typing/inking       #
#-------------------------------------------#

# Optional diagnostic data off (AllowTelemetry = 1 basic, 0 security on some SKUs)
# HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection
$dataCollKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
New-Item -Path $dataCollKey -Force | Out-Null
Set-ItemProperty -Path $dataCollKey -Name "AllowTelemetry" -Type DWord -Value 1

# Improve inking & typing off
# HKCU\Software\Microsoft\Input\TIPC  Enabled = 0
$tipcKey = "HKCU:\Software\Microsoft\Input\TIPC"
New-Item -Path $tipcKey -Force | Out-Null
Set-ItemProperty -Path $tipcKey -Name "Enabled" -Type DWord -Value 0

Write-Host "Diagnostic and input-related data collection reduced." -ForegroundColor Green

#-------------------------------------------#
# 6. Lock screen: Spotlight & promos       #
#-------------------------------------------#

# Switch from Windows Spotlight to Picture
# HKCU\Software\Microsoft\Windows\CurrentVersion\Lock Screen
$lockKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
New-Item -Path $lockKey -Force | Out-Null
# 1 = Picture, 2 = Slideshow, 3 = Windows Spotlight (varies by build; 1 is safe for Picture)
Set-ItemProperty -Path $lockKey -Name "CreativeLockScreenSource" -Type DWord -Value 1

# Disable fun facts, tips, tricks on lock screen
# HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0  # fun facts
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0  # tips
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0  # more promos
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0  # lock screen suggestions/widgets

Write-Host "Lock screen ads and promos disabled." -ForegroundColor Green

#-------------------------------------------#
# 7. System tips & suggestion notifications#
#-------------------------------------------#

# Get tips and suggestions when using Windows
# HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager
Set-ItemProperty -Path $cdmKey -Name "SoftLandingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0  # tips & suggestions
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0  # welcome experience
Set-ItemProperty -Path $cdmKey -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0  # setup suggestions

Write-Host "System tips and suggestion notifications disabled." -ForegroundColor Green

#-------------------------------------------#
# 8. File Explorer sync provider nudges    #
#-------------------------------------------#

# Disable “Show sync provider notifications”
# HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced  ShowSyncProviderNotifications = 0
Set-ItemProperty -Path $advKey -Name "ShowSyncProviderNotifications" -Type DWord -Value 0

Write-Host "File Explorer sync provider notifications disabled." -ForegroundColor Green

#-------------------------------------------#
# 9. Finish                                #
#-------------------------------------------#

Write-Host "`nAll tweaks applied. A sign-out or reboot is recommended for everything to fully take effect." -ForegroundColor Cyan
