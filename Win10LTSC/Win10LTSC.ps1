# iwr https://github.com/philmorinca/Powershell/raw/refs/heads/main/Win10LTSC/Win10LTSC.ps1 -UseBasicParsing | iex
Clear-Host
$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

$ISODownloadPath = "C:\Win10LTSC.iso"
$CMDDownloadPath = "C:\setupcomplete.cmd"

Write-Host -ForegroundColor Red "Will reinstall Win10 LTSC. Proceed?"
Pause

if (!(Test-Path $ISODownloadPath)) {
    Start-BitsTransfer -Source "https://r2.philmorin.net/Win10LTSC.$((Get-WinSystemLocale).Name).iso" -Destination $ISODownloadPath
}

if (!(Test-Path $CMDDownloadPath)) {
    Start-BitsTransfer -Source "https://github.com/philmorinca/Powershell/raw/refs/heads/main/Win10LTSC/setupcomplete.cmd" -Destination $CMDDownloadPath
}

Mount-DiskImage -ImagePath $ISODownloadPath -PassThru

$drive = Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'CES_X64*'}

if ($drive) {
    $drive = $drive.Name

    Set-Location $drive

    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name "EditionID" -Value "EnterpriseS" 
    & .\setup.exe /auto upgrade /compat ignorewarning /EULA accept /PostOOBE $CMDDownloadPath
}
