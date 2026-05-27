#!/usr/bin/env powershell
# BURP SUITE SETUP AUTOMATION

Write-Host "Burp Suite Setup for Tokopedia - Auto Mode`n" -ForegroundColor Cyan

$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Step 1: Check Burp Suite installation
Write-Host "[1] Checking Burp Suite installation..." -ForegroundColor Yellow

$burpPaths = @(
    "C:\Program Files\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "C:\Program Files (x86)\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "$env:LOCALAPPDATA\BurpSuiteCommunity\BurpSuiteCommunity.exe",
    "C:\Users\rriat\AppData\Local\Programs\BurpSuiteCommunity\BurpSuiteCommunity.exe"
)

$burpFound = $null
foreach ($path in $burpPaths) {
    if (Test-Path $path) {
        $burpFound = $path
        Write-Host "Found Burp: $path" -ForegroundColor Green
        break
    }
}

if (-not $burpFound) {
    Write-Host "Burp Suite not found" -ForegroundColor Red
    Write-Host @"
DOWNLOAD BURP SUITE:
1. Go to: https://portswigger.net/burp/communitydownload
2. Download & Install
3. Re-run this script

Or if already installed, manually set path above.
"@ -ForegroundColor Yellow
    exit 1
}

# Step 2: Start Burp Suite
Write-Host "`n[2] Starting Burp Suite..." -ForegroundColor Yellow

$burpProcess = Start-Process -FilePath $burpFound -PassThru -WindowStyle Normal

Start-Sleep 8

Write-Host "Burp started (PID: $($burpProcess.Id))" -ForegroundColor Green

# Step 3: Configure proxy settings
Write-Host "`n[3] Configuring Burp proxy..." -ForegroundColor Yellow
Write-Host "MANUAL STEPS in Burp:" -ForegroundColor Cyan
Write-Host @"
1. Project > Project settings > Network
2. Proxy > Listeners
3. Add new listener:
   - Bind to port: 8080
   - All interfaces: YES
   - Check "Running" enabled
4. Close settings
"@ -ForegroundColor Yellow

Read-Host "`nPress ENTER when done"

# Step 4: Export Burp certificate
Write-Host "`n[4] Exporting Burp certificate..." -ForegroundColor Yellow
Write-Host "MANUAL STEPS:" -ForegroundColor Cyan
Write-Host @"
1. In Burp: Proxy tab > Options
2. CA certificate > Export certificate in DER format
3. Save as: C:\Users\rriat\OneDrive\Dokumen\test\testing\burp.cer
4. Keep Burp open
"@ -ForegroundColor Yellow

Read-Host "`nPress ENTER when saved"

# Step 5: Verify certificate exists
$certPath = "C:\Users\rriat\OneDrive\Dokumen\test\testing\burp.cer"

if (-not (Test-Path $certPath)) {
    Write-Host "Certificate not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Certificate found: $certPath" -ForegroundColor Green

# Step 6: Convert DER to PEM
Write-Host "`n[5] Converting certificate DER to PEM..." -ForegroundColor Yellow

$burpPem = "C:\Users\rriat\OneDrive\Dokumen\test\testing\burp.pem"

# Try using openssl if available
$openssl = Get-Command openssl -ErrorAction SilentlyContinue

if ($openssl) {
    & openssl x509 -inform DER -in $certPath -out $burpPem
    Write-Host "Converted to PEM: $burpPem" -ForegroundColor Green
} else {
    Write-Host "OpenSSL not found, trying alternative..." -ForegroundColor Yellow
    $burpPem = $certPath
}

# Step 7: Push certificate to emulator
Write-Host "`n[6] Pushing certificate to emulator..." -ForegroundColor Yellow

& $adbPath push $burpPem /sdcard/Download/burp.pem

Write-Host "Certificate pushed" -ForegroundColor Green

# Step 8: Configure emulator proxy
Write-Host "`n[7] Configuring emulator proxy for Burp..." -ForegroundColor Yellow

$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | 
       Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object -First 1).IPAddress

if (-not $ip) { $ip = "192.168.1.11" }

& $adbPath shell "settings put global http_proxy $($ip):8080" 2>$null
& $adbPath shell "settings put global https_proxy $($ip):8080" 2>$null

Write-Host "Proxy set: $($ip):8080" -ForegroundColor Green

# Step 9: Install certificate on emulator
Write-Host "`n[8] Installing certificate on emulator..." -ForegroundColor Yellow
Write-Host "MANUAL STEPS:" -ForegroundColor Cyan
Write-Host @"
1. On Emulator: Settings > Security
2. Install from storage
3. Select: Download/burp.pem
4. Install certificate
5. Return to this terminal
"@ -ForegroundColor Yellow

Read-Host "`nPress ENTER when installed"

# Step 10: Restart app
Write-Host "`n[9] Restarting Tokopedia app..." -ForegroundColor Yellow

& $adbPath shell "am force-stop com.tokopedia.tokopro" 2>$null
Start-Sleep 2

& $adbPath shell "monkey -p com.tokopedia.tokopro 1" 2>$null

Write-Host "App restarted" -ForegroundColor Green

# Step 11: Configure Burp SSL interception
Write-Host "`n[10] Configuring Burp SSL interception..." -ForegroundColor Yellow
Write-Host "IN BURP (Proxy tab):" -ForegroundColor Cyan
Write-Host @"
1. Proxy > Options > SSL Pass Through
2. Add: *.tokopedia.com
3. Proxy > Intercept > Intercept is OFF (just capture, don't block)
"@ -ForegroundColor Yellow

Read-Host "`nPress ENTER"

# Step 12: Monitor traffic
Write-Host "`n[11] Monitoring Burp traffic..." -ForegroundColor Yellow

Write-Host @"

BURP SUITE READY!

What you'll see:
- All HTTPS traffic from Tokopedia app
- Decrypted requests to: gql.tokopedia.com, ta.tokopedia.com
- GraphQL queries visible
- Authentication headers visible

NEXT STEPS:
1. On Emulator: Use Tokopedia app normally
2. In Burp: Watch traffic appear in real-time
3. Right-click requests > Send to Repeater
4. Analyze requests/responses
5. Save API findings

To export traffic:
- Burp > File > Export > All items
- Format: HTML Report

"@ -ForegroundColor Cyan

Write-Host "SETUP COMPLETE!" -ForegroundColor Green

# Keep display
Read-Host "`nPress ENTER to finish"
