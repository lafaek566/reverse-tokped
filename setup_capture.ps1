#!/usr/bin/env powershell

# Setup for Tokopedia Lite Traffic Capture
# Prerequisites:
# 1. Burp listening on 8080
# 2. Emulator has internet
# 3. Tokopedia app installed

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Tokopedia Lite Capture Setup                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
Set-Alias adb $adbPath
$device = "emulator-5554"

# Get host IP (LAN IP, not localhost)
Write-Host "STEP 1: Get Host IP Address" -ForegroundColor Yellow
$hostIP = (adb -s $device shell "ip route" | Select-String "default" | ForEach-Object { 
    $parts = $_.ToString().Split()
    $parts[2] 
}) 

Write-Host "Host IP detected: $hostIP`n" -ForegroundColor Green

# Setup proxy
Write-Host "STEP 2: Configure Emulator Proxy" -ForegroundColor Yellow
adb -s $device shell "settings put global http_proxy ${hostIP}:8080"
adb -s $device shell "settings put global https_proxy ${hostIP}:8080"
Write-Host "Proxy set to: ${hostIP}:8080`n" -ForegroundColor Green

# Verify proxy
Write-Host "STEP 3: Verify Proxy Configuration" -ForegroundColor Yellow
$proxyStatus = adb -s $device shell "settings get global http_proxy"
Write-Host "Current proxy: $proxyStatus`n" -ForegroundColor Green

# Check Tokopedia app
Write-Host "STEP 4: Check Tokopedia App Installation" -ForegroundColor Yellow
$tokopediaApp = adb -s $device shell "pm list packages" | Select-String "tokopedia"
if ($tokopediaApp) {
    Write-Host "Found Tokopedia apps:" -ForegroundColor Green
    $tokopediaApp | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "No Tokopedia app found!" -ForegroundColor Red
}
Write-Host ""

# Check Burp on host
Write-Host "STEP 5: Verify Burp is Running" -ForegroundColor Yellow
$burpRunning = Test-NetConnection -ComputerName localhost -Port 8080 -WarningAction SilentlyContinue
if ($burpRunning.TcpTestSucceeded) {
    Write-Host "Burp is listening on port 8080" -ForegroundColor Green
} else {
    Write-Host "Burp is NOT listening on port 8080!" -ForegroundColor Red
    Write-Host "Start Burp first: burpsuite.exe"
}
Write-Host ""

# Clear Burp history for clean capture
Write-Host "STEP 6: Prepare for Clean Capture" -ForegroundColor Yellow
Write-Host "Emulator and Burp are ready!" -ForegroundColor Green
Write-Host ""

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  NEXT: Launch Tokopedia Lite                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nTO CAPTURE TRAFFIC:

1. In Burp, go to: Proxy > HTTP History (clear any old data)

2. On emulator, launch Tokopedia Lite app:
   adb -s emulator-5554 shell am start -n com.tokopedia.tokopro/.MainActivity

3. Navigate in the app (search products, browse categories, etc)

4. Watch traffic appear in Burp > Proxy > HTTP History

5. To export API endpoints:
   Right-click on request > Copy as cURL
   Or view in Repeater for full request/response

TIPS:
- Check 'Intercept' OFF in Proxy tab (unless debugging)
- Filter by tokopedia.com in HTTP History
- Look for /gql or /search API calls
- Take note of headers like X-Tkpd-* for authentication
"
