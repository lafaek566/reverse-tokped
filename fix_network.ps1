$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$device = "emulator-5554"

Write-Host "`n=== Fixing Emulator Internet ===" -ForegroundColor Cyan

# Set DNS explicitly
Write-Host "Setting DNS servers..."
& $adb -s $device shell "setprop net.dns1 8.8.8.8"
& $adb -s $device shell "setprop net.dns2 8.8.4.4"

# Verify DNS
Write-Host "`nVerifying DNS..."
$dns1 = & $adb -s $device shell "getprop net.dns1"
Write-Host "DNS1: $dns1" -ForegroundColor Green

# Restart networking
Write-Host "`nRestarting network..."
& $adb -s $device shell "svc wifi disable"
Start-Sleep -Seconds 2
& $adb -s $device shell "svc wifi enable"
Start-Sleep -Seconds 3

# Test ping
Write-Host "`nTesting connectivity..."
$pingTest = & $adb -s $device shell "ping -c 1 8.8.8.8" 2>&1
if ($pingTest -match "bytes") {
    Write-Host "✅ Internet works!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Still having issues" -ForegroundColor Yellow
}

Write-Host ""
