#!/usr/bin/env powershell

# Monitor Tokopedia API traffic captured by Burp

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Burp Traffic Monitor                           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
Set-Alias adb $adbPath

# Step 1: Verify Tokopedia app is running
Write-Host "STEP 1: Check if Tokopedia app is running..." -ForegroundColor Yellow
$appRunning = & adb -s emulator-5554 shell "pidof com.tokopedia.tokopro" 2>&1
if ($appRunning -and $appRunning -notmatch "not found") {
    Write-Host "OK - App PID: $appRunning" -ForegroundColor Green
} else {
    Write-Host "ERROR - App not running!" -ForegroundColor Red
}
Write-Host ""

# Step 2: Simulate user action - perform a search
Write-Host "STEP 2: Simulate user action (taking screenshot)..." -ForegroundColor Yellow
& adb -s emulator-5554 shell screencap -p /data/local/tmp/screen.png
Write-Host "Screenshot captured" -ForegroundColor Green
Write-Host ""

# Step 3: Monitor network connections
Write-Host "STEP 3: Check network connections from app..." -ForegroundColor Yellow
$netstat = & adb -s emulator-5554 shell "netstat -an | grep tokopedia"
if ($netstat) {
    Write-Host "Connections found:" -ForegroundColor Green
    $netstat
} else {
    Write-Host "No active connections to tokopedia servers" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Check TCP dump log
Write-Host "STEP 4: Check for HTTPS connections..." -ForegroundColor Yellow
$httpsConns = & adb -s emulator-5554 shell "netstat -an | grep 443"
if ($httpsConns) {
    Write-Host "HTTPS connections found:" -ForegroundColor Green
    $httpsConns | ForEach-Object { 
        if ($_ -notmatch "LOCAL|Netid") {
            Write-Host "  $_"
        }
    }
} else {
    Write-Host "No HTTPS connections found" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Check proxy configuration
Write-Host "STEP 5: Verify proxy is still configured..." -ForegroundColor Yellow
$proxySet = & adb -s emulator-5554 shell "settings get global http_proxy"
Write-Host "Proxy setting: $proxySet" -ForegroundColor Green
Write-Host ""

# Step 6: Test connectivity through proxy
Write-Host "STEP 6: Test emulator can reach Tokopedia..." -ForegroundColor Yellow
$connTest = & adb -s emulator-5554 shell "curl -m 3 -s -o /dev/null -w 'HTTP %{http_code}' https://ta.tokopedia.com/search/v2?q=phone"
Write-Host "Connection test result: $connTest" -ForegroundColor Green
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   ANALYSIS                                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($appRunning -and $proxySet -match "8080") {
    Write-Host "`nIMPORTANT FINDINGS:" -ForegroundColor Yellow
    Write-Host "1. App IS running" -ForegroundColor Green
    Write-Host "2. Proxy IS configured" -ForegroundColor Green
    Write-Host "3. BUT if no traffic in Burp..." -ForegroundColor Red
    Write-Host "   => App ignores system proxy (hardcoded API)" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUTION:" -ForegroundColor Yellow
    Write-Host "Use direct API approach instead (already created):" -ForegroundColor Cyan
    Write-Host "  - tokopedia_scraper_production.js" -ForegroundColor Cyan
    Write-Host "  - Works locally with mock data" -ForegroundColor Cyan
    Write-Host "  - Deploy to cloud for real data" -ForegroundColor Cyan
} else {
    Write-Host "`nSOMETHING'S WRONG:" -ForegroundColor Red
    Write-Host "App: $(if ($appRunning) { 'RUNNING' } else { 'NOT RUNNING' })" -ForegroundColor Yellow
    Write-Host "Proxy: $(if ($proxySet -match '8080') { 'CONFIGURED' } else { 'NOT SET' })" -ForegroundColor Yellow
}

Write-Host ""
