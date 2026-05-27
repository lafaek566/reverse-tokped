$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$device = "emulator-5554"

Write-Host "`n=== Removing Proxy (Apps Bypass It Anyway) ===" -ForegroundColor Cyan

# Clear proxy
Write-Host "Removing proxy settings..."
& $adb -s $device shell "settings delete global http_proxy" 2>&1 | Out-Null
& $adb -s $device shell "settings delete global https_proxy" 2>&1 | Out-Null
& $adb -s $device shell "settings delete global global_http_proxy_host" 2>&1 | Out-Null
& $adb -s $device shell "settings delete global global_http_proxy_port" 2>&1 | Out-Null

Start-Sleep -Seconds 1

# Verify
$proxy = & $adb -s $device shell "settings get global http_proxy" 2>&1
Write-Host "Proxy now: $proxy`n" -ForegroundColor Green

# Restart apps
Write-Host "Killing apps..."
& $adb -s $device shell "am force-stop com.tokopedia.tokopro"
& $adb -s $device shell "am force-stop com.google.android.youtube"

Start-Sleep -Seconds 2

Write-Host "`n✅ Proxy removed! Apps should now have internet." -ForegroundColor Green
Write-Host "YouTube dan Tokopedia should work normally now`n" -ForegroundColor Cyan
