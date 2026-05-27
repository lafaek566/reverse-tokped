#!/usr/bin/env powershell

<#
  Android Emulator Internet Connectivity Diagnostic
  Checks why emulator has no internet access
#>

Write-Host "╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Android Emulator Network Diagnostic                 ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Find ADB
$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
    Write-Host "❌ ADB not found at: $adbPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ ADB found`n" -ForegroundColor Green

# Set alias
Set-Alias adb $adbPath

# 2. Check devices
Write-Host "📱 Connected Devices:" -ForegroundColor Yellow
adb devices
Write-Host ""

# 3. Check emulator network settings
Write-Host "🌐 Network Configuration on Emulator:" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────"

# Get DNS info
Write-Host "`n📡 DNS Resolution:"
adb shell "getprop net.dns1"
adb shell "getprop net.dns2"

# Get IP configuration
Write-Host "`n🔗 IP Configuration:"
adb shell "ip route"
adb shell "ifconfig wlan0" -ErrorAction SilentlyContinue
adb shell "ip addr" -ErrorAction SilentlyContinue

# Test connectivity FROM emulator
Write-Host "`n🧪 Internet Test FROM Emulator:" -ForegroundColor Yellow
Write-Host "Pinging 8.8.8.8..."
adb shell "ping -c 1 8.8.8.8" 2>&1 | Select-String "bytes from|unreachable|timeout" | Select-Object -First 1

Write-Host "`nPinging 1.1.1.1 (Cloudflare DNS)..."
adb shell "ping -c 1 1.1.1.1" 2>&1 | Select-String "bytes from|unreachable|timeout" | Select-Object -First 1

Write-Host "`nPinging ta.tokopedia.com..."
adb shell "ping -c 1 ta.tokopedia.com" 2>&1 | Select-String "bytes from|unreachable|timeout" | Select-Object -First 1

# Emulator network interface status
Write-Host "`n📊 Network Interface Status:" -ForegroundColor Yellow
adb shell "netstat -an" 2>&1 | Select-Object -First 5

Write-Host "`n╔═══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  RESULTS ABOVE ↑                                     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n💡 SOLUTIONS if no internet:

1️⃣ Check Emulator Network Settings:
   - Open AVD Manager → Edit → Advanced Settings
   - Network: NAT (not None)
   - DNS: 8.8.8.8

2️⃣ Restart Emulator:
   adb emu kill
   # Then restart from AVD Manager

3️⃣ Check Host Network:
   ipconfig /all (from host)
   # Verify host has internet

4️⃣ Reset Emulator Network:
   adb shell 'settings put global captive_portal_server 0'

5️⃣ Verify Host Can Reach Tokopedia:
   ping ta.tokopedia.com (from host)
   # If this fails, ISP is blocking
"
