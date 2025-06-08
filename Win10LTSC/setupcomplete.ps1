$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

Remove-Item "C:\setupcomplete.cmd" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Win10LTSC.iso" -Force -ErrorAction SilentlyContinue

#Activate windows
& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID

