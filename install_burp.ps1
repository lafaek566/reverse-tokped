#!/usr/bin/env powershell
# AUTO DOWNLOAD & INSTALL BURP SUITE COMMUNITY

Write-Host "Downloading Burp Suite Community Edition`n" -ForegroundColor Cyan

$downloadUrl = "https://portswigger.net/burp/communitydownload?requestededition=community"
$installerPath = "C:\Users\rriat\Downloads\burp-community-windows.exe"

Write-Host "[1] Downloading Burp..." -ForegroundColor Yellow

try {
    # Download with progress
    $ProgressPreference = 'Continue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -TimeoutSec 300
    Write-Host "Downloaded: $installerPath" -ForegroundColor Green
} catch {
    Write-Host "Download failed. Manual download required:" -ForegroundColor Red
    Write-Host $downloadUrl -ForegroundColor Yellow
    exit 1
}

# Step 2: Check if installer exists
if (-not (Test-Path $installerPath)) {
    Write-Host "Installer not found after download" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2] Starting Burp Suite installation..." -ForegroundColor Yellow

# Run installer
$process = Start-Process -FilePath $installerPath -Wait -PassThru

Write-Host "Installation completed (Exit code: $($process.ExitCode))" -ForegroundColor Green

# Verify installation
Write-Host "`n[3] Verifying installation..." -ForegroundColor Yellow

$burpPaths = @(
    "C:\Program Files\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "C:\Program Files (x86)\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "$env:LOCALAPPDATA\BurpSuiteCommunity\BurpSuiteCommunity.exe"
)

$burpFound = $null
foreach ($path in $burpPaths) {
    if (Test-Path $path) {
        $burpFound = $path
        Write-Host "Burp installed: $path" -ForegroundColor Green
        break
    }
}

if ($burpFound) {
    Write-Host "`nBurp ready! Run: burp_setup_auto.ps1 next" -ForegroundColor Cyan
} else {
    Write-Host "Installation not verified. Please install manually." -ForegroundColor Yellow
}
