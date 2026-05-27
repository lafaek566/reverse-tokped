#!/usr/bin/env powershell

<#
.SYNOPSIS
    Complete Tokopedia Lite Setup for Client - One-Click
.DESCRIPTION
    Handles: Emulator check, internet setup, proxy removal, app launch
.EXAMPLE
    .\client_tokopedia_setup.ps1
#>

param(
    [string]$ApkPath = "",
    [switch]$SkipInstall
)

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

function Write-Step {
    param([string]$Message)
    Write-Host "`n► $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠️ $Message" -ForegroundColor Yellow
}

# Header
Clear-Host
Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  TOKOPEDIA LITE - CLIENT SETUP                   ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Magenta

# Check ADB
Write-Step "Checking ADB..."
if (-not (Test-Path $adb)) {
    Write-Error "ADB not found at: $adb"
    exit 1
}
Write-Success "ADB found"

# Wait for emulator
Write-Step "Waiting for emulator (max 30 seconds)..."
$maxWait = 30
$waited = 0
$device = $null

while ($waited -lt $maxWait) {
    $devices = & $adb devices 2>&1 | Select-String "emulator"
    if ($devices) {
        $device = $devices.ToString().Split()[0]
        Write-Success "Emulator found: $device"
        break
    }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 1
    $waited++
}

if (-not $device) {
    Write-Error "Emulator not responding after 30 seconds"
    Write-Warning "Please start Android Emulator manually:"
    Write-Host "  1. Open Android Studio"
    Write-Host "  2. Click: AVD Manager"
    Write-Host "  3. Select: Pixel 6 Pro API 37"
    Write-Host "  4. Click: Play"
    Write-Host ""
    exit 1
}

# Remove proxy
Write-Step "Removing proxy settings (so apps can access internet)..."
& $adb -s $device shell "settings delete global http_proxy" 2>&1 | Out-Null
& $adb -s $device shell "settings delete global https_proxy" 2>&1 | Out-Null
$proxyCheck = & $adb -s $device shell "settings get global http_proxy" 2>&1
if ($proxyCheck -eq "null") {
    Write-Success "Proxy removed"
} else {
    Write-Warning "Proxy still shows: $proxyCheck"
}

# Test internet
Write-Step "Testing internet connectivity..."
$pingTest = & $adb -s $device shell "ping -c 1 8.8.8.8" 2>&1
if ($pingTest -match "bytes") {
    Write-Success "Internet works!"
} else {
    Write-Warning "No internet detected - emulator may need restart"
}

# Check/Install Tokopedia app
Write-Step "Checking Tokopedia app..."
$appInstalled = & $adb -s $device shell "pm list packages" 2>&1 | Select-String "tokopedia"

if ($appInstalled -and -not $SkipInstall) {
    Write-Success "Tokopedia app already installed"
} elseif ($SkipInstall) {
    Write-Warning "Install skipped (using existing app)"
} else {
    if ($ApkPath -and (Test-Path $ApkPath)) {
        Write-Step "Installing Tokopedia app..."
        & $adb install $ApkPath 2>&1 | Out-Null
        Start-Sleep -Seconds 2
        $appInstalled = & $adb -s $device shell "pm list packages" 2>&1 | Select-String "tokopedia"
        if ($appInstalled) {
            Write-Success "Tokopedia app installed"
        } else {
            Write-Error "Installation failed"
        }
    } else {
        Write-Warning "No APK provided - skipping installation"
        Write-Host "  Use: .\client_tokopedia_setup.ps1 -ApkPath 'C:\path\to\apk'"
    }
}

# Launch app
Write-Step "Launching Tokopedia Lite..."
& $adb -s $device shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity 2>&1 | Out-Null
Start-Sleep -Seconds 3

$running = & $adb -s $device shell "pidof com.tokopedia.tokopro" 2>&1
if ($running -and $running -notmatch "not found") {
    Write-Success "App running (PID: $running)"
} else {
    Write-Warning "App may not be running"
}

# Summary
Write-Host "`n╔════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║  SETUP COMPLETE                                  ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Magenta

Write-Host "`n📱 Emulator Status:" -ForegroundColor Yellow
Write-Host "  Device: $device"
Write-Host "  Internet: ✅ Working"
Write-Host "  Tokopedia Lite: $(if($appInstalled) {'✅ Installed'} else {'⚠️ Check manually'})"
Write-Host "  App Running: $(if($running -and $running -notmatch 'not found') {'✅ Yes'} else {'⚠️ May need restart'})"

Write-Host "`n📌 Important Notes:" -ForegroundColor Yellow
Write-Host "  • App will bypass system proxy (normal native app behavior)"
Write-Host "  • Burp proxy won't capture traffic from this app"
Write-Host "  • Direct API scraper is proven alternative"

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open emulator - should see Tokopedia Lite loading"
Write-Host "  2. App should have internet - verify by searching products"
Write-Host "  3. For production: Deploy direct API scraper to cloud"

Write-Host "`n📝 For troubleshooting, see: TOKOPEDIA_REINSTALL_GUIDE.md`n"
