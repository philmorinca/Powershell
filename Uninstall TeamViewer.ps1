& $((Get-Item "C:\Program File*\TeamViewer\Uninstall.exe" | Select-Object -First 1 FullName).FullName) /S
Get-Item "C:\Program File*\TeamViewer" | Remove-Item -Recurse -Force -Confirm:$false 
