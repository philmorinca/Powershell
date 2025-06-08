$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

Get-Item "C:\setupcomplete.cmd" | Remove-Item -Force #-ErrorAction SilentlyContinue
Get-Item "C:\Win10LTSC.iso" | Remove-Item -Force #-ErrorAction SilentlyContinue

#Activate windows
& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID

