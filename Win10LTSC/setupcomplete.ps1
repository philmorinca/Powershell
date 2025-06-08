$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

#Activate windows
& ([ScriptBlock]::Create((Invoke-RestMethod https://get.activated.win))) /HWID