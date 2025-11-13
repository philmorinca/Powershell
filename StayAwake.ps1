# iwr https://github.com/philmorinca/Powershell/raw/refs/heads/main/StayAwake.ps1 -UseBasicParsing | iex
powercfg /x -hibernate-timeout-ac 0
powercfg /x -disk-timeout-ac 0
powercfg /x -standby-timeout-ac 0
