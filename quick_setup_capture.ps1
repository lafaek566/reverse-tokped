#!/usr/bin/env powershell

Write-Host "`n=== Full Tokopedia Lite Capture Setup ===" -ForegroundColor Cyan

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
Set-Alias adb $adbPath

# Wait for emulator
Write-Host "Waiting for emulator to respond..."
for ($i = 0; $i -lt 5; $i++) {
    $devices = & adb devices 2>&1 | Select-String "emulator"
    if ($devices) {
        Write-Host "Emulator found!" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
}

$device = "emulator-5554"

# Get host IP
$hostIP = & adb -s $device shell "ip route" | ForEach-Object { 
    $parts = $_.ToString().Split()
    if ($parts.Count -gt 2) { $parts[2] }
} | Select-Object -First 1

Write-Host "Host IP: $hostIP" -ForegroundColor Green

# Set proxy
Write-Host "Setting proxy to ${hostIP}:8080..."
& adb -s $device shell "settings put global http_proxy ${hostIP}:8080"
& adb -s $device shell "settings put global https_proxy ${hostIP}:8080"

# Verify
$proxy = & adb -s $device shell "settings get global http_proxy" 2>&1
Write-Host "Proxy now: $proxy" -ForegroundColor Green

# Launch app
Write-Host "`nLaunching Tokopedia Lite..."
& adb -s $device shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity
Start-Sleep -Seconds 3

# Check if running
$pid = & adb -s $device shell "pidof com.tokopedia.tokopro" 2>&1
Write-Host "App running with PID: $pid" -ForegroundColor Green

Write-Host "`n✅ Setup complete! Navigate the app to capture traffic." -ForegroundColor Cyan
Write-Host "Open Burp: Proxy > HTTP History to see captured requests`n" -ForegroundColor Yellow
