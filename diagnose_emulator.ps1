#!/usr/bin/env powershell

# Android Emulator Internet Connectivity Check

Write-Host "`n=== Android Emulator Network Diagnostic ===" -ForegroundColor Cyan

# Find ADB
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
    Write-Host "ERROR: ADB not found at: $adbPath" -ForegroundColor Red
    Write-Host "`nTry: Add ADB to PATH or install Android SDK"
    exit 1
}

Set-Alias adb $adbPath
Write-Host "OK: ADB found`n" -ForegroundColor Green

# Check devices
Write-Host "STEP 1: Connected Devices" -ForegroundColor Yellow
adb devices
Write-Host ""

# Get emulator name
$device = adb devices | Select-String "emulator" | Select-Object -First 1 | ForEach-Object { $_.ToString().Split()[0] }
if (-not $device) {
    Write-Host "ERROR: No emulator connected!" -ForegroundColor Red
    exit 1
}

Write-Host "OK: Emulator found: $device`n" -ForegroundColor Green

# Check DNS
Write-Host "STEP 2: DNS Configuration" -ForegroundColor Yellow
Write-Host "DNS1: $(adb -s $device shell getprop net.dns1)"
Write-Host "DNS2: $(adb -s $device shell getprop net.dns2)`n"

# Check network connectivity
Write-Host "STEP 3: Network Connectivity Tests" -ForegroundColor Yellow

Write-Host "Testing 8.8.8.8 (Google DNS)..."
$ping1 = adb -s $device shell "ping -c 1 8.8.8.8 2>&1"
if ($ping1 -match "bytes from") {
    Write-Host "  OK - Internet reachable" -ForegroundColor Green
} else {
    Write-Host "  FAIL - No internet" -ForegroundColor Red
}

Write-Host "`nTesting ta.tokopedia.com..."
$ping2 = adb -s $device shell "ping -c 1 ta.tokopedia.com 2>&1"
if ($ping2 -match "bytes from") {
    Write-Host "  OK - Tokopedia reachable" -ForegroundColor Green
} else {
    Write-Host "  FAIL - Cannot reach Tokopedia" -ForegroundColor Red
}

# Show result
Write-Host "`n=== DIAGNOSIS ===" -ForegroundColor Cyan
if ($ping1 -match "bytes from") {
    Write-Host "SUCCESS: Emulator has internet!" -ForegroundColor Green
    Write-Host "`nYou can now:"
    Write-Host "1. Launch Tokopedia app"
    Write-Host "2. Configure proxy: 192.168.1.11:8080"
    Write-Host "3. Open Burp to see traffic"
} else {
    Write-Host "PROBLEM: Emulator has no internet" -ForegroundColor Red
    Write-Host "`nSOLUTIONS:"
    Write-Host "1. Check host internet: ping 8.8.8.8"
    Write-Host "2. Restart emulator: adb emu kill"
    Write-Host "3. Edit emulator settings (NAT network)"
    Write-Host "4. Check firewall/proxy on host"
}

Write-Host ""
