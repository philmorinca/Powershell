# iwr https://... | iex
Clear-Host
$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

$ISODownloadPath = "C:\Win10LTSC.iso"

Start-BitsTransfer -Source "https://raw.github.patate/Win10STSC.$((Get-WinSystemLocale).Name).iso" -Destination $ISODownloadPath
Mount-DiskImage -ImagePath $ISODownloadPath -PassThru

$drive = Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'CES_X64*'}

if ($drive) {
    $drive = $drive.Name

    Set-Location $drive
    Write-Host -ForegroundColor Red "Will reinstall Win10 LTSC. Proceed?"
    Pause


    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name "EditionID" -Value "EnterpriseS" -WhatIf

}
