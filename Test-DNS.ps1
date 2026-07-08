Write-Host "=== TEST LATENCE DNS ==="
 
$Hostname = "perdu.com"
$Iterations = 10
$Results = @()
 
Write-Host "Test DNS sur : $Hostname"
Write-Host "Nombre de tests : $Iterations`n"
 
for ($i = 1; $i -le $Iterations; $i++) {
 
    $time = Measure-Command {
        Resolve-DnsName $Hostname | Out-Null
    }
 
    $ms = [math]::Round($time.TotalMilliseconds, 2)
    $Results += $ms
 
    Write-Host "Test $i : $ms ms"
}
 
$avg = [math]::Round(($Results | Measure-Object -Average).Average, 2)
$min = ($Results | Measure-Object -Minimum).Minimum
$max = ($Results | Measure-Object -Maximum).Maximum
 
Write-Host "`n=== RESULTATS ==="
Write-Host "Latence DNS moyenne : $avg ms"
Write-Host "Latence DNS minimum : $min ms"
Write-Host "Latence DNS maximum : $max ms"
Write-Host "=== FIN TEST ==="
