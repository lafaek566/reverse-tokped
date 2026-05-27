#!/usr/bin/env powershell

# Proper Tokopedia Lite Capture Setup

Write-Host "`n=== Tokopedia Lite Capture Setup (PROPER) ===" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
Set-Alias adb $adbPath

$device = "emulator-5554"

# Get ACTUAL IP address from gateway (not interface name)
Write-Host "Step 1: Get host IP address..."
$routeOutput = & adb -s $device shell "ip route"
Write-Host "Route output: $routeOutput"

# Extract IP properly
$hostIP = $routeOutput | ForEach-Object {
    if ($_ -match "default via (\d+\.\d+\.\d+\.\d+)") {
        $matches[1]
    }
}

if (-not $hostIP) {
    Write-Host "ERROR: Could not extract IP! Using fallback..."
    $hostIP = "192.168.1.11"
}

Write-Host "Host IP: $hostIP`n" -ForegroundColor Green

# Remove old proxy first
Write-Host "Step 2: Clear old proxy settings..."
& adb -s $device shell "settings delete global http_proxy" 2>&1 | Out-Null
& adb -s $device shell "settings delete global https_proxy" 2>&1 | Out-Null
Start-Sleep -Seconds 1

# Set new proxy
Write-Host "Setting proxy to ${hostIP}:8080..."
& adb -s $device shell "settings put global http_proxy ${hostIP}:8080"
& adb -s $device shell "settings put global https_proxy ${hostIP}:8080"

# Verify
$proxyCheck = & adb -s $device shell "settings get global http_proxy" 2>&1
Write-Host "Proxy now: $proxyCheck`n" -ForegroundColor Green

# Kill app first
Write-Host "Step 3: Restarting app with new proxy..."
& adb -s $device shell "am force-stop com.tokopedia.tokopro"
Start-Sleep -Seconds 1

# Launch app
& adb -s $device shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity
Start-Sleep -Seconds 3

# Check if running
$appPID = & adb -s $device shell "pidof com.tokopedia.tokopro" 2>&1
if ($appPID -and $appPID -notmatch "not found") {
    Write-Host "✅ App running with PID: $appPID`n" -ForegroundColor Green
} else {
    Write-Host "⚠️ App may not be running properly`n" -ForegroundColor Yellow
}

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  NEXT: Check Burp for Traffic                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "TO CAPTURE REQUESTS:" -ForegroundColor Yellow
Write-Host "1. Open Burp at: http://127.0.0.1:8080" -ForegroundColor Cyan
Write-Host "2. Go to Proxy > HTTP History" -ForegroundColor Cyan
Write-Host "3. CLEAR history (empty it)" -ForegroundColor Cyan
Write-Host "4. On emulator: Open app, search products, navigate" -ForegroundColor Cyan
Write-Host "5. Watch traffic appear in Burp HTTP History" -ForegroundColor Cyan
Write-Host "6. Look for requests to: ta.tokopedia.com, gql.tokopedia.com" -ForegroundColor Cyan
Write-Host "`nNote: If NO traffic appears:" -ForegroundColor Red
Write-Host "      App likely ignores system proxy (hardcoded API calls)" -ForegroundColor Red
Write-Host "      Solution: Use direct API scraper instead" -ForegroundColor Red
Write-Host ""
