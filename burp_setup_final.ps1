#!/usr/bin/env powershell
# ============================================================================
# BURP SUITE - COMPLETE SETUP + TOKOPEDIA TRAFFIC CAPTURE
# ============================================================================
# This script automates complete Burp setup for Tokopedia API interception:
# 1. Download & install Burp (if needed)
# 2. Start Burp Suite
# 3. Extract CA certificate (auto)
# 4. Configure Android emulator proxy
# 5. Install certificate to emulator
# 6. Verify and start traffic capture
# ============================================================================

$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"

# Colors for output
$colors = @{
    "header" = "Cyan"
    "success" = "Green"
    "warning" = "Yellow"
    "error" = "Red"
    "info" = "White"
}

function Write-Log {
    param([string]$message, [string]$color = "info")
    Write-Host $message -ForegroundColor $colors[$color]
}

# ============================================================================
# STEP 1: Check/Install Burp Suite
# ============================================================================
Write-Log "`n[STEP 1] Checking Burp Suite Installation...`n" "header"

$burpPaths = @(
    "C:\Program Files\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "C:\Program Files (x86)\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "$env:LOCALAPPDATA\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "C:\Users\rriat\AppData\Local\Programs\BurpSuiteCommunity\BurpSuiteCommunity.exe"
)

$burpPath = $null
foreach ($path in $burpPaths) {
    if (Test-Path $path) {
        $burpPath = $path
        Write-Log "✓ Burp found: $path" "success"
        break
    }
}

if (-not $burpPath) {
    Write-Log "✗ Burp Suite not found" "error"
    Write-Log "`nDOWNLOAD & INSTALL NOW:`n" "warning"
    Write-Log "1. Go to: https://portswigger.net/burp/communitydownload" "info"
    Write-Log "2. Download BurpSuiteCommunity-Windows-*.exe" "info"
    Write-Log "3. Run installer (default location OK)" "info"
    Write-Log "4. Return here and run this script again`n" "info"
    
    Read-Host "Press ENTER after installing Burp"
    exit 1
}

# ============================================================================
# STEP 2: Verify Android SDK/ADB
# ============================================================================
Write-Log "`n[STEP 2] Checking Android SDK...`n" "header"

$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adbPath)) {
    Write-Log "✗ ADB not found at: $adbPath" "error"
    Write-Log "Install Android SDK platform-tools or set ANDROID_HOME env var" "warning"
    exit 1
}

Write-Log "✓ ADB found: $adbPath" "success"

# Check devices
$devices = & $adbPath devices
$deviceList = $devices | Select-Object -Skip 1 | Where-Object { $_ -ne "" -and $_ -notmatch "^List" }

if ($deviceList.Count -eq 0) {
    Write-Log "✗ No Android devices/emulator connected" "error"
    Write-Log "`nFix:" "warning"
    Write-Log "1. Start Android emulator (from Android Studio)" "info"
    Write-Log "2. Or connect Android device with USB debugging enabled" "info"
    Write-Log "3. Run: adb devices" "info"
    Write-Log "4. Return here and run this script again`n" "info"
    exit 1
}

Write-Log "✓ Devices found:" "success"
foreach ($device in $deviceList) {
    Write-Log "  - $device" "info"
}

# Get first device
$targetDevice = $deviceList[0].Split()[0]

# ============================================================================
# STEP 3: Start Burp Suite
# ============================================================================
Write-Log "`n[STEP 3] Starting Burp Suite...`n" "header"

$burpProcess = Get-Process -Name "BurpSuiteCommunity*" -ErrorAction SilentlyContinue

if (-not $burpProcess) {
    Write-Log "Starting Burp (this may take 10-20 seconds)..." "info"
    
    Start-Process -FilePath $burpPath -WindowStyle Minimized
    
    # Wait for Burp to start and open browser
    Write-Log "Waiting for Burp to initialize..." "warning"
    for ($i = 1; $i -le 15; $i++) {
        Start-Sleep 1
        $burpProcess = Get-Process -Name "BurpSuiteCommunity*" -ErrorAction SilentlyContinue
        if ($burpProcess) {
            break
        }
        Write-Host "." -NoNewline
    }
    Write-Host "`n" -NoNewline
    
    if ($burpProcess) {
        Write-Log "✓ Burp started (PID: $($burpProcess.Id))" "success"
        Start-Sleep 3
    } else {
        Write-Log "✗ Burp failed to start" "error"
        exit 1
    }
} else {
    Write-Log "✓ Burp already running (PID: $($burpProcess.Id))" "success"
}

# ============================================================================
# STEP 4: Extract Burp CA Certificate
# ============================================================================
Write-Log "`n[STEP 4] Extracting Burp CA Certificate...`n" "header"

$certDest = "C:\Users\rriat\OneDrive\Dokumen\test\testing\burp-cacert.pem"
$burpDataDir = "$env:USERPROFILE\.burp"

# Try to find certificate in Burp user data directory
$cacertSource = "$burpDataDir\cacert.der"

if (Test-Path $cacertSource) {
    Write-Log "Found Burp certificate: $cacertSource" "info"
    
    # Convert DER to PEM
    $certutil = "certutil.exe"
    
    Write-Log "Converting DER → PEM..." "info"
    & $certutil -encode $cacertSource $certDest -f
    
    if (Test-Path $certDest) {
        Write-Log "✓ Certificate exported: $certDest" "success"
    } else {
        Write-Log "⚠ Auto-export failed. Manual step required:" "warning"
        $manualStep = $true
    }
} else {
    Write-Log "⚠ Burp certificate not found at auto-location" "warning"
    $manualStep = $true
}

if ($manualStep) {
    Write-Log "`nMANUAL EXPORT REQUIRED:" "warning"
    Write-Log "1. Open Burp Suite (should already be running)" "info"
    Write-Log "2. Go to: Proxy → Options → CA Certificate" "info"
    Write-Log "3. Click 'Save...'" "info"
    Write-Log "4. Select 'Certificate in DER format'" "info"
    Write-Log "5. Save as: burp-cacert.der" "info"
    Write-Log "6. Location: C:\Users\rriat\OneDrive\Dokumen\test\testing\" "info"
    Write-Log "`nThen press ENTER to continue...`n" "info"
    
    Read-Host "After exporting certificate, press ENTER"
    
    # Try to find the DER file
    $manualDER = "C:\Users\rriat\OneDrive\Dokumen\test\testing\burp-cacert.der"
    if (Test-Path $manualDER) {
        Write-Log "Found manual export: $manualDER" "success"
        
        # Convert to PEM
        Write-Log "Converting DER → PEM..." "info"
        & $certutil -encode $manualDER $certDest -f
        
        if (Test-Path $certDest) {
            Write-Log "✓ Certificate ready: $certDest" "success"
        } else {
            Write-Log "✗ Conversion failed" "error"
            exit 1
        }
    } else {
        Write-Log "✗ Certificate file not found" "error"
        exit 1
    }
}

# ============================================================================
# STEP 5: Get Burp Proxy IP/Port
# ============================================================================
Write-Log "`n[STEP 5] Configuring Burp Proxy...`n" "header"

$hostIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | 
    Select-Object -ExpandProperty IPv4Address | 
    Select-Object -ExpandProperty IPAddress)[0]

if (-not $hostIP) {
    # Fallback
    $hostIP = "192.168.1.X"
    Write-Log "⚠ Could not detect host IP, using placeholder: $hostIP" "warning"
    Write-Log "You may need to set proxy manually in emulator" "warning"
}

$proxyPort = "8080"  # Default Burp proxy port

Write-Log "Host IP detected: $hostIP" "info"
Write-Log "Burp Proxy: $hostIP`:$proxyPort" "info"

# ============================================================================
# STEP 6: Configure Emulator Proxy
# ============================================================================
Write-Log "`n[STEP 6] Configuring Android Emulator Proxy...`n" "header"

Write-Log "Setting device proxy via adb..." "info"

# Set proxy for all traffic
& $adbPath -s $targetDevice shell settings put global http_proxy "$hostIP`:$proxyPort"
& $adbPath -s $targetDevice shell settings put global https_proxy "$hostIP`:$proxyPort"

Write-Log "✓ Proxy configured on device: $targetDevice" "success"

# ============================================================================
# STEP 7: Install Certificate to Device
# ============================================================================
Write-Log "`n[STEP 7] Installing Burp Certificate to Device...`n" "header"

# Push certificate to device
Write-Log "Pushing certificate to device..." "info"
& $adbPath -s $targetDevice push $certDest /sdcard/burp-cacert.pem

# The user will need to manually install from Settings on the emulator
# But we can try to install via adb shell if system cert dir is writable
& $adbPath -s $targetDevice shell 'am start -a android.settings.SETTINGS' 2>$null

Write-Log "`nManual installation required:" "warning"
Write-Log "1. On emulator: Settings → Security → Install from SD card" "info"
Write-Log "2. Select: burp-cacert.pem" "info"
Write-Log "3. Name: Burp CA" "info"
Write-Log "4. Used for: VPN and apps" "info"
Write-Log "`nPress ENTER after installing certificate..." "info"

Read-Host "Continue"

# ============================================================================
# STEP 8: Verify Connection
# ============================================================================
Write-Log "`n[STEP 8] Verifying Setup...`n" "header"

Write-Log "Testing connectivity..." "info"

# Try a simple ping to verify device is responsive
$testCmd = & $adbPath -s $targetDevice shell "ping -c 1 8.8.8.8" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Log "✓ Device network OK" "success"
} else {
    Write-Log "⚠ Device network test inconclusive" "warning"
}

# ============================================================================
# STEP 9: Start Traffic Capture
# ============================================================================
Write-Log "`n[STEP 9] Ready for Traffic Capture`n" "header"

Write-Log "Setup complete! Now:" "success"
Write-Log "`n1. Open Tokopedia app on emulator" "info"
Write-Log "2. Watch traffic in Burp → Proxy → HTTP History" "info"
Write-Log "3. Interact with app to capture API calls" "info"
Write-Log "4. Right-click traffic → Send to Repeater for analysis" "info"

Write-Log "`nKey Burp Features:" "info"
Write-Log "  • HTTP History: All captured traffic" "info"
Write-Log "  • Decoder: Decode base64, JWT, etc" "info"
Write-Log "  • Repeater: Replay requests manually" "info"
Write-Log "  • Intruder: Automation & scanning" "info"

Write-Log "`nTo clear proxy (disable capture):" "warning"
Write-Log '  adb shell settings put global http_proxy :0' "info"
Write-Log '  adb shell settings put global https_proxy :0' "info"

Write-Log "`n✓ Burp Tokopedia setup complete!`n" "success"

Write-Host "Press ENTER to exit..." -ForegroundColor Gray
Read-Host
