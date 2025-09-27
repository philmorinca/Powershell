# iwr https://github.com/philmorinca/Powershell/raw/refs/heads/main/Win10LTSC/Win10LTSC.ps1 -UseBasicParsing | iex
Clear-Host
$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Bypass -Scope Process

function Download-FileMultiConnection {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination,

        [int]$MaxConnections = 8,
        [int]$MinChunkSizeMB = 1,
        [int]$MaxChunkSizeMB = 50,
        [int]$MaxRetries = 3,
        [int]$RetryDelaySeconds = 2
    )

    # Convert MB to bytes
    $minChunkSize = $MinChunkSizeMB * 1MB
    $maxChunkSize = $MaxChunkSizeMB * 1MB

    # Random temp folder
    $randomId = [guid]::NewGuid().ToString()
    $tempFolder = "$env:TEMP\DownloadChunks_$randomId"
    mkdir $tempFolder -Force | Out-Null

    # Get file size
    $response = Invoke-WebRequest -Uri $Source -Method Head
    $fileSize = [int64]$response.Headers["Content-Length"]

    # Calculate chunk size
    $initialChunkSize = [math]::Ceiling($fileSize / $MaxConnections)
    $chunkSize = [math]::Max($minChunkSize, [math]::Min($initialChunkSize, $maxChunkSize))

    # Create byte ranges
    $ranges = @()
    for ($start = 0; $start -lt $fileSize; $start += $chunkSize) {
        $end = [math]::Min($start + $chunkSize - 1, $fileSize - 1)
        $ranges += @{Start=$start; End=$end}
    }

    # Progress tracking
    $progressFile = "$tempFolder\progress.txt"
    Set-Content -Path $progressFile -Value "0"

    # Start download jobs
    $jobs = @()
    for ($i = 0; $i -lt $ranges.Count; $i++) {
        $range = $ranges[$i]
        $chunkPath = "$tempFolder\chunk_$i"
        $jobs += Start-Job -ScriptBlock {
            param($url, $range, $chunkPath, $progressFile, $maxRetries, $retryDelay)

            $success = $false
            $attempt = 0
            while (-not $success -and $attempt -lt $maxRetries) {
                try {
                    Invoke-WebRequest -Uri $url -Headers @{Range="bytes=$($range.Start)-$($range.End)"} -OutFile $chunkPath -ErrorAction Stop
                    $bytesDownloaded = (Get-Item $chunkPath).Length
                    Add-Content -Path $progressFile -Value $bytesDownloaded
                    $success = $true
                } catch {
                    Start-Sleep -Seconds $retryDelay
                    $attempt++
                }
            }

            if (-not $success) {
                Write-Error "Failed to download chunk $chunkPath after $maxRetries attempts."
            }
        } -ArgumentList $Source, $range, $chunkPath, $progressFile, $MaxRetries, $RetryDelaySeconds
    }

    # Monitor progress
    while ($jobs | Where-Object { $_.State -ne 'Completed' }) {
        Start-Sleep -Seconds 1
        $downloaded = (Get-Content $progressFile | Measure-Object -Sum).Sum
        $percent = [math]::Round(($downloaded / $fileSize) * 100, 2)
        Write-Progress -Activity "Downloading file" -Status "$percent% complete" -PercentComplete $percent
    }

    # Finalize jobs
    $jobs | Wait-Job
    $jobs | ForEach-Object { Receive-Job $_; Remove-Job $_ }

    # Combine chunks
    $chunkFiles = Get-ChildItem $tempFolder -Filter "chunk_*" | Sort-Object Name
    $combined = [System.IO.File]::Create($Destination)
    foreach ($chunk in $chunkFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($chunk.FullName)
        $combined.Write($bytes, 0, $bytes.Length)
    }
    $combined.Close()

    # Cleanup
    Remove-Item $tempFolder -Recurse -Force
}

$ISODownloadPath = "C:\Win10LTSC.iso"
$CMDDownloadPath = "C:\setupcomplete.cmd"

Write-Host -ForegroundColor Red "Will reinstall Win10 LTSC. Proceed?"
Pause

if (!(Test-Path $ISODownloadPath)) {
    Download-FileMultiConnection -Source "https://r2.philmorin.net/Win10LTSC.$((Get-WinSystemLocale).Name).iso" -Destination $ISODownloadPath
}

if (!(Test-Path $CMDDownloadPath)) {
    Download-FileMultiConnection -Source "https://github.com/philmorinca/Powershell/raw/refs/heads/main/Win10LTSC/setupcomplete.cmd" -Destination $CMDDownloadPath
}

Mount-DiskImage -ImagePath $ISODownloadPath -PassThru

$drive = Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'CES_X64*'}

if ($drive) {
    $drive = $drive.Name

    Set-Location $drive

    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion" -Name "EditionID" -Value "EnterpriseS" 
    & .\setup.exe /auto upgrade /compat ignorewarning /EULA accept /PostOOBE $CMDDownloadPath
}
