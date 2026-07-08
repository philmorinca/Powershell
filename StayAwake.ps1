# iwr "https://raw.githubusercontent.com/philmorinca/Powershell/refs/heads/main/StayAwake.ps1?t=$(Get-Date -UFormat %s)" -UseBasicParsing | iex
powercfg /x -hibernate-timeout-ac 0
powercfg /x -disk-timeout-ac 0
powercfg /x -standby-timeout-ac 0
