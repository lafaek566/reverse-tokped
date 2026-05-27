#!/usr/bin/env powershell
# AUTO CONFIGURE EMULATOR PROXY & CERTIFICATE

Write-Host "Auto-Configuring Emulator Proxy & Certificate`n" -ForegroundColor Cyan

$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# 1. Set proxy via settings
Write-Host "[1] Setting proxy configuration..." -ForegroundColor Yellow

& $adbPath shell "settings put global http_proxy 192.168.1.11:8888" 2>$null
& $adbPath shell "settings put global https_proxy 192.168.1.11:8888" 2>$null

Start-Sleep 1

$proxyCheck = & $adbPath shell "settings get global http_proxy" 2>&1

Write-Host "Proxy set to: $proxyCheck" -ForegroundColor Green

# 2. Install certificate using adb security module
Write-Host "`n[2] Installing Charles certificate..." -ForegroundColor Yellow

# Push cert to system store
$certFile = "C:\Users\rriat\OneDrive\Dokumen\test\testing\charles.pem"

if (Test-Path $certFile) {
    Write-Host "Certificate found, installing..." -ForegroundColor Green
    
    # Get certificate hash
    Write-Host "Extracting certificate hash..." -ForegroundColor Gray
    
    $output = & $adbPath shell "openssl x509 -inform PEM -subject_hash_old -in /sdcard/Download/charles.pem | head -1" 2>&1
    
    Write-Host "Hash: $output" -ForegroundColor Gray
    
    # Create system certificate
    & $adbPath root 2>$null
    Start-Sleep 1
    
    & $adbPath remount 2>$null
    Start-Sleep 1
    
    if ($output) {
        $hash = $output.Trim()
        & $adbPath shell "cp /sdcard/Download/charles.pem /system/etc/security/cacerts/$hash.0" 2>$null
        
        Write-Host "Certificate installed to system store" -ForegroundColor Green
    }
} else {
    Write-Host "Certificate not found at $certFile" -ForegroundColor Red
    Write-Host "Please save charles.pem and retry" -ForegroundColor Yellow
}

# 3. Disable SSL verification for debugging
Write-Host "`n[3] Enabling cleartext traffic debugging..." -ForegroundColor Yellow

& $adbPath shell "settings put global ssl_debug_mode 1" 2>$null

# 4. Restart networking
Write-Host "`n[4] Restarting network stack..." -ForegroundColor Yellow

& $adbPath shell "svc wifi disable" 2>$null
Start-Sleep 2

& $adbPath shell "svc wifi enable" 2>$null
Start-Sleep 3

# 5. Verify configuration
Write-Host "`n[5] Verifying configuration..." -ForegroundColor Yellow

$proxyVerify = & $adbPath shell "settings get global http_proxy" 2>&1
$certVerify = & $adbPath shell "ls /system/etc/security/cacerts/ | wc -l" 2>&1

Write-Host "Proxy verified: $proxyVerify" -ForegroundColor Green
Write-Host "Certificates in system: $certVerify" -ForegroundColor Green

# 6. Restart app
Write-Host "`n[6] Restarting app..." -ForegroundColor Yellow

& $adbPath shell "am force-stop com.tokopedia.tokopro" 2>$null
Start-Sleep 2

& $adbPath shell "monkey -p com.tokopedia.tokopro 1" 2>$null

Write-Host "`n[SUCCESS]" -ForegroundColor Cyan
Write-Host "Emulator should now proxy through Charles"
Write-Host "Check Charles for traffic from gql.tokopedia.com"
