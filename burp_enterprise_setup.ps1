#!/usr/bin/env powershell
# =============================================================================
# BURP ENTERPRISE - SETUP FOR TOKOPEDIA TESTING
# =============================================================================

Write-Host "`n=== BURP ENTERPRISE SETUP FOR TOKOPEDIA ===" -ForegroundColor Cyan
Write-Host "Setting up Android emulator proxy + certificate install`n" -ForegroundColor White

# Step 1: Check ADB
Write-Host "[1] Checking Android SDK..." -ForegroundColor Yellow
$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adbPath)) {
    Write-Host "ERROR: ADB not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ ADB found" -ForegroundColor Green

# Step 2: Check devices
Write-Host "`n[2] Checking Android devices..." -ForegroundColor Yellow
$devices = & $adbPath devices
$deviceList = $devices | Select-Object -Skip 1 | Where-Object { $_ -ne "" -and $_ -notmatch "^List" }

if ($deviceList.Count -eq 0) {
    Write-Host "ERROR: No devices found!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Devices found:" -ForegroundColor Green
foreach ($device in $deviceList) {
    Write-Host "  - $device" -ForegroundColor White
}

$targetDevice = $deviceList[0].Split()[0]

# Step 3: Get host IP
Write-Host "`n[3] Detecting host IP..." -ForegroundColor Yellow
$hostIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | 
    Select-Object -ExpandProperty IPv4Address | 
    Select-Object -ExpandProperty IPAddress)[0]

if (-not $hostIP) {
    $hostIP = "192.168.1.100"
    Write-Host "WARNING: Could not detect IP, using: $hostIP" -ForegroundColor Yellow
} else {
    Write-Host "✓ Host IP: $hostIP" -ForegroundColor Green
}

# Step 4: Configure Burp proxy on emulator
Write-Host "`n[4] Configuring proxy on emulator..." -ForegroundColor Yellow
$proxyPort = "8080"
$proxyAddr = "$hostIP`:$proxyPort"

Write-Host "Setting proxy: $proxyAddr" -ForegroundColor White
& $adbPath -s $targetDevice shell settings put global http_proxy "$proxyAddr"
& $adbPath -s $targetDevice shell settings put global https_proxy "$proxyAddr"

Write-Host "✓ Proxy configured" -ForegroundColor Green

# Step 5: Export Burp certificate
Write-Host "`n[5] Burp Certificate Setup..." -ForegroundColor Yellow
Write-Host "This is MANUAL - you need to:" -ForegroundColor White
Write-Host "  1. Open Burp Enterprise: https://localhost:8443/" -ForegroundColor Cyan
Write-Host "  2. Go to: Settings → Proxy → Options → CA Certificate" -ForegroundColor Cyan
Write-Host "  3. Click: Download certificate (PEM/DER format)" -ForegroundColor Cyan
Write-Host "  4. Save as: burp-cert.pem in your project folder" -ForegroundColor Cyan
Write-Host "  5. Then run: adb push burp-cert.pem /sdcard/" -ForegroundColor Cyan

Read-Host "`nPress ENTER after downloading certificate"

# Check if cert exists
$certFile = "C:\Users\rriat\OneDrive\Dokumen\test\testing\burp-cert.pem"
if (-not (Test-Path $certFile)) {
    $certFile = Read-Host "Enter path to certificate file (or press ENTER to skip)"
    
    if (-not (Test-Path $certFile)) {
        Write-Host "Certificate not found, skipping..." -ForegroundColor Yellow
        $certFile = $null
    }
}

if ($certFile) {
    Write-Host "`n[6] Installing certificate to emulator..." -ForegroundColor Yellow
    & $adbPath -s $targetDevice push $certFile /sdcard/burp-cert.pem
    Write-Host "✓ Certificate pushed to device" -ForegroundColor Green
    
    Write-Host "`nNow on emulator:" -ForegroundColor Yellow
    Write-Host "  1. Open: Settings → Security → Install from SD card" -ForegroundColor White
    Write-Host "  2. Select: burp-cert.pem" -ForegroundColor White
    Write-Host "  3. Name: Burp CA" -ForegroundColor White
    
    Read-Host "`nPress ENTER after certificate installed"
}

# Step 7: Ready for testing
Write-Host "`n[7] SETUP COMPLETE!" -ForegroundColor Green
Write-Host "`nYou can now:" -ForegroundColor Cyan
Write-Host "  1. Open Tokopedia app on emulator" -ForegroundColor White
Write-Host "  2. Go to Burp → Proxy → HTTP History" -ForegroundColor White
Write-Host "  3. Watch traffic appear in real-time!" -ForegroundColor White

Write-Host "`nBurp Enterprise URL:" -ForegroundColor Yellow
Write-Host "  https://localhost:8443/" -ForegroundColor Cyan

Write-Host "`nTo disable proxy after testing:" -ForegroundColor Yellow
Write-Host "  adb shell settings put global http_proxy :0" -ForegroundColor White
Write-Host "  adb shell settings put global https_proxy :0`n" -ForegroundColor White

Read-Host "Press ENTER to exit"
