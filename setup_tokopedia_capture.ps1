$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

Write-Host "`n=== Tokopedia Lite Internet & Capture Setup ===" -ForegroundColor Cyan

# Wait for emulator
Write-Host "`nWaiting for emulator..."
$maxWait = 10
$waited = 0
while ($waited -lt $maxWait) {
    $devices = & $adb devices 2>&1 | Select-String "emulator"
    if ($devices) {
        Write-Host "✅ Emulator found!" -ForegroundColor Green
        break
    }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
    $waited++
}

if ($waited -eq $maxWait) {
    Write-Host "`n❌ Emulator not responding. Please start Android Emulator manually." -ForegroundColor Red
    exit 1
}

$device = "emulator-5554"
Write-Host ""

# Remove any proxy
Write-Host "Step 1: Ensure NO proxy (so apps can access internet)"
& $adb -s $device shell "settings delete global http_proxy" 2>&1 | Out-Null
& $adb -s $device shell "settings delete global https_proxy" 2>&1 | Out-Null

# Verify no proxy
$proxyCheck = & $adb -s $device shell "settings get global http_proxy" 2>&1
Write-Host "Proxy status: $proxyCheck ✓`n" -ForegroundColor Green

# Test internet
Write-Host "Step 2: Test internet connectivity"
$pingTest = & $adb -s $device shell "ping -c 1 8.8.8.8" 2>&1
if ($pingTest -match "bytes") {
    Write-Host "✅ Internet works!" -ForegroundColor Green
} else {
    Write-Host "⚠️ No internet yet, may need restart" -ForegroundColor Yellow
}
Write-Host ""

# Check Tokopedia app
Write-Host "Step 3: Check Tokopedia Lite app"
$appCheck = & $adb -s $device shell "pm list packages" 2>&1 | Select-String "tokopedia"
if ($appCheck) {
    Write-Host "✅ Tokopedia app installed: $appCheck" -ForegroundColor Green
} else {
    Write-Host "❌ Tokopedia app NOT installed!" -ForegroundColor Red
    Write-Host "   Need to install first"
}
Write-Host ""

# Launch app
Write-Host "Step 4: Launch Tokopedia Lite"
& $adb -s $device shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity 2>&1 | Out-Null
Start-Sleep -Seconds 3

$running = & $adb -s $device shell "pidof com.tokopedia.tokopro" 2>&1
if ($running -and $running -notmatch "not found") {
    Write-Host "✅ App running (PID: $running)" -ForegroundColor Green
} else {
    Write-Host "⚠️ App may not be running" -ForegroundColor Yellow
}

Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  READY FOR CAPTURE                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nNow you can:
1. Open Tokopedia Lite on emulator
2. Burp will NOT see traffic (app bypasses proxy)
3. Use direct API scraper for production

Or reinstall Tokopedia Lite:
  adb install <path_to_apk>`n"
