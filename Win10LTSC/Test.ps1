$ISOs = Get-ChildItem -Path C:\Users\*.iso -Recurse
$ISODownloadPath = $($ISOs | Select-Object -First 1 ).FullPath
Mount-DiskImage -ImagePath $ISODownloadPath -PassThru

$drive = Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'CES_X64*'}

if ($drive) {
    $drive = $drive.Name

    Set-Location $drive
    Write-Host -ForegroundColor Red "Will reinstall Win10 LTSC. Proceed?"
    Pause


    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name "EditionID" -Value "EnterpriseS" -WhatIf

}
