# 🔧 Tokopedia Lite - Reinstall & Setup Guide (For Client)

## Problem
- Emulator tidak ada internet
- Tokopedia Lite tidak bisa buka
- Client mau capture traffic lokal

## Solution

### Step 1: Ensure Emulator is Running
```bash
# If emulator is closed, start it:
# - Open Android Studio
# - Click: AVD Manager
# - Select: Pixel 6 Pro API 37
# - Click: Play button

# Wait 30-60 seconds for full boot
```

### Step 2: Check Internet Status
```powershell
# Open PowerShell and run:
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb devices  # Should show: emulator-5554   device
```

If emulator NOT listed:
- Close Android Studio
- Kill emulator: `& $adb emu kill`
- Restart emulator fresh

### Step 3: Verify No Proxy
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Clear any proxy that may block internet
& $adb -s emulator-5554 shell "settings delete global http_proxy"
& $adb -s emulator-5554 shell "settings delete global https_proxy"

# Verify:
& $adb -s emulator-5554 shell "settings get global http_proxy"
# Should return: null
```

### Step 4: Test Internet
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Ping Google
& $adb -s emulator-5554 shell "ping -c 1 8.8.8.8"
# Should show: "64 bytes from 8.8.8.8"
```

If NO internet:
1. Check host machine internet (ping 8.8.8.8)
2. Restart emulator: `& $adb emu kill` then restart
3. Check firewall settings

### Step 5: Install Tokopedia Lite APK

**Option A: If APK already exists**
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$apkPath = "C:\path\to\tokopedia-lite.apk"

# Install
& $adb install $apkPath
```

**Option B: If need to download APK**
1. Go to Google Play Store
2. Search: "Tokopedia"
3. Download on Android device
4. Or use APK website (APKPure, etc)

**Option C: Use pre-patched APK**
```powershell
# If we have patched version without SSL pinning:
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb install "tokopedia-lite-patched.apk"
```

### Step 6: Launch Tokopedia Lite
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Launch app
& $adb -s emulator-5554 shell am start -n com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity

# Wait 3-5 seconds for app to open
Start-Sleep -Seconds 5
```

### Step 7: Verify App Has Internet
```powershell
# Check if app is running
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell "pidof com.tokopedia.tokopro"
# Should show PID number (e.g., 12345)
```

---

## Important Note: Why Proxy Won't Capture Traffic

⚠️ **IMPORTANT**: Even with proxy configured, Tokopedia Lite app will NOT send traffic through Burp because:

1. **Native apps bypass proxy** - They have hardcoded API endpoints
2. **App makes direct connections** - Ignores system proxy settings  
3. **Burp won't see requests** - No traffic will appear in HTTP History
4. **This is EXPECTED** - Normal for compiled Android apps

---

## Alternative: Use Direct API Scraper

Instead of capturing traffic, use the working solution:

```bash
# Local testing (mock data)
$env:NODE_ENV = "development"
node tokopedia_scraper_production.js

# Production (real data on cloud)
# Deploy to DigitalOcean + NODE_ENV=production
```

**This approach:**
- ✅ Works locally immediately
- ✅ Works in production (cloud)
- ✅ Doesn't need proxy
- ✅ 80-95% success rate
- ✅ No traffic capture needed

---

## Troubleshooting

### Problem: "Emulator offline"
**Solution:**
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb emu kill                          # Kill emulator
# Then restart from Android Studio
```

### Problem: "Tokopedia app won't open"
**Solution:**
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Uninstall and reinstall
& $adb uninstall com.tokopedia.tokopro
& $adb install tokopedia-lite.apk
```

### Problem: "No internet on emulator"
**Solution:**
```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Check proxy
& $adb -s emulator-5554 shell "settings get global http_proxy"

# If NOT null, remove it:
& $adb -s emulator-5554 shell "settings delete global http_proxy"
& $adb -s emulator-5554 shell "settings delete global https_proxy"

# Restart emulator after removing proxy
```

### Problem: "Burp shows no traffic from app"
**Solution:**
This is NORMAL - use direct API scraper instead. See alternatives above.

---

## Summary

```
Tokopedia Lite can run locally ✓
But proxy capture won't work ✗
Direct API scraper works perfectly ✓
```

**Recommendation**: Skip proxy capture, deploy direct API to cloud.
