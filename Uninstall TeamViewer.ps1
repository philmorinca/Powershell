& $((Get-Item "C:\Program File*\TeamViewer\Uninstall.exe" | Select-Object -First 1 FullName).FullName) /S
