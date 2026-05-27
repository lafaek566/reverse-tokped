$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
Set-Alias adb $adbPath

$device = "emulator-5554"

Write-Host "`n=== Tokopedia Capture Setup ===" -ForegroundColor Cyan

# Get host IP
Write-Host "Getting host IP..."
$routeOutput = & adb -s $device shell "ip route"
$hostIP = $routeOutput | ForEach-Object {
    if ($_ -match "default via (\d+\.\d+\.\d+\.\d+)") {
        $matches[1]
    }
}

if (-not $hostIP) {
    $hostIP = "192.168.1.11"
}

Write-Host "Host IP: $hostIP`n" -ForegroundColor Green

# Clear proxy
& adb -s $device shell "settings delete global http_proxy" 2>&1 | Out-Null
& adb -s $device shell "settings delete global https_proxy" 2>&1 | Out-Null

# Set proxy
Write-Host "Setting proxy to ${hostIP}:8080..."
& adb -s $device shell "settings put global http_proxy ${hostIP}:8080"
& adb -s $device shell "settings put global https_proxy ${hostIP}:8080"

# Restart app
Write-Host "Restarting app..."
& adb -s $device shell "am force-stop com.tokopedia.tokopro"
Start-Sleep -Seconds 1

& adb -s $device shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity
Start-Sleep -Seconds 3

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "App is running. Check Burp Proxy > HTTP History for traffic.`n" -ForegroundColor Cyan
