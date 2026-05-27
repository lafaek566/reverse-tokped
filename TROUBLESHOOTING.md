# Troubleshooting & FAQ

Complete troubleshooting guide untuk APK Patcher.

## 🔍 Diagnostics Commands

Jalankan command ini untuk diagnose masalah:

```powershell
# Check Python
python --version
python -c "import sys; print(sys.executable)"

# Check Java
java -version
where java

# Check apktool
apktool --version
where apktool

# Check jarsigner
jarsigner -help
where jarsigner

# Check if debug keystore exists
Test-Path "$HOME\.android\debug.keystore"

# Check if ADB is available
adb version
adb devices

# List your PATH
$env:Path -split ';'
```

---

## ❌ Common Issues & Solutions

### Issue 1: `apktool: command not found`

**Symptoms:**
```
Menjalankan: apktool d target.apk
Command tidak ditemukan: [Errno 2] No such file or directory: 'apktool'
```

**Diagnosis:**
```powershell
apktool --version   # Returns: not found
where apktool       # Returns: nothing
```

**Solutions:**

**Option A: Install via Scoop (Easiest)**
```powershell
# Install scoop if not yet
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')

# Install apktool
scoop install apktool

# Verify
apktool --version
```

**Option B: Install via Chocolatey**
```powershell
# Install chocolatey if not yet (run as Admin)
# From: https://chocolatey.org/install

# Install apktool
choco install apktool

# Verify
apktool --version
```

**Option C: Manual Installation**
```powershell
# 1. Download from https://ibotpeaches.github.io/Apktool/
# 2. Extract to C:\apktool

# 3. Add to PATH (run as Admin):
$apktoolPath = "C:\apktool"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$apktoolPath", "User")

# 4. Restart PowerShell/Terminal

# 5. Verify
apktool --version
```

---

### Issue 2: `jarsigner: command not found`

**Symptoms:**
```
Tool signing ditemukan: jarsigner
jarsigner tidak ditemukan di PATH
```

**Diagnosis:**
```powershell
jarsigner -help     # Returns: not found
where jarsigner     # Returns: nothing
java -version       # OK
```

**Root Cause:** Java JRE installed, bukan JDK. JRE tidak include jarsigner.

**Solutions:**

**Option A: Install JDK (Recommended)**
```powershell
# Download Java JDK (not JRE)
# https://www.oracle.com/java/technologies/downloads/

# Or use Chocolatey:
choco install openjdk

# Verify
java -version
jarsigner -help

# If still not found, add to PATH:
$jdkPath = "C:\Program Files\Java\jdk-21.0.1\bin"  # Adjust version
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$jdkPath", "User")

# Restart PowerShell
jarsigner -help
```

**Option B: Use keytool to create keystore**
```powershell
# If jarsigner still not found, try keytool:
keytool -help

# If keytool works but jarsigner doesn't:
# Path is usually: C:\Program Files\Java\jdk-21.0.1\bin\jarsigner.exe
# Add this specific path to your PATH
```

---

### Issue 3: `Debug keystore not found`

**Symptoms:**
```
Debug keystore tidak ditemukan: C:\Users\username\.android\debug.keystore
```

**Solutions:**

**Option A: Run setup_check.py (Automatic)**
```powershell
python setup_check.py

# Will automatically create debug.keystore
```

**Option B: Manual Creation**
```powershell
# Find keytool
where keytool

# Create keystore (run exactly - for Java 17+):
keytool -genkeypair -v -keystore $HOME\.android\debug.keystore `
  -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass android -keypass android `
  -dname "CN=Android Debug,O=Android,C=US"

# Verify
Test-Path $HOME\.android\debug.keystore
```

**Option C: Provide custom keystore**
```python
# Edit sign_apk_with_jarsigner() in apk_patcher.py
# Change keystore_path to your keystore:

keystore_path = Path("C:/path/to/my/keystore.jks")
storepass = "your_storepass"
keypass = "your_keypass"
```

---

### Issue 4: `XML Parse Error - AndroidManifest.xml`

**Symptoms:**
```
XML Parse error di AndroidManifest.xml: ...
element name is required at line ...
```

**Causes:**
1. AndroidManifest.xml sudah dimodifikasi (re-patching)
2. APK corrupt
3. Encoding issue

**Solutions:**

**Option A: Use fresh APK**
```powershell
# Delete any previously decompiled folders
rm myapp -Recurse -Force

# Start fresh with original APK
python apk_patcher.py myapp.apk
```

**Option B: Check XML validity**
```powershell
# Verify APK not corrupt
$file = Get-Item "myapp.apk"
Write-Host "File size: $($file.Length) bytes"

# If very small (< 100 KB), APK might be corrupt
```

**Option C: Try different APK**
```powershell
# Test with a different APK
python apk_patcher.py different_app.apk
```

---

### Issue 5: `APK Installation Failed`

**Symptoms:**
```
adb install patched.apk
→ Failure [INSTALL_FAILED_...]
```

**Common Sub-issues:**

**A) Already Installed**
```powershell
# Uninstall first
adb uninstall com.example.app

# Then install
adb install patched.apk
```

**B) Architecture Mismatch**
```powershell
# Check device architecture
adb shell getprop ro.product.cpu.abi

# Check APK architectures
# Inside APK: lib/arm64-v8a, lib/armeabi-v7a, etc
# Should match device

# If mismatch, get universal/correct APK
```

**C) Target API Version Mismatch**
```powershell
# Check device Android version
adb shell getprop ro.build.version.release

# APK requires lower or equal version
# If APK requires Android 12 but device has 11, won't install
```

**D) Insufficient Storage**
```powershell
# Check device storage
adb shell df /data

# Free up space on device
adb shell pm clear [some_old_app]  # Clear cache
```

**E) APK Not Signed Properly**
```powershell
# Verify APK is signed
jarsigner -verify -certs patched.apk

# Should output: "jar verified"
# If not, re-sign manually
```

**Solution: Detailed Install Log**
```powershell
# Get more info
adb logcat -c
adb install patched.apk
adb logcat | Select-String "INSTALL"

# This shows the real reason
```

---

### Issue 6: `Device Not Found (adb)`

**Symptoms:**
```
adb install patched.apk
→ error: no devices found
```

**Diagnosis:**
```powershell
adb devices          # Returns empty list
adb version          # Should show version
```

**Solutions:**

**For Physical Device:**
```powershell
# 1. Enable Developer Mode
#    Settings → About Phone → Build Number (tap 7 times)

# 2. Enable USB Debugging
#    Settings → Developer Options → USB Debugging

# 3. Connect via USB

# 4. Check connection
adb devices

# 5. If "unauthorized", approve on device popup
```

**For Android Emulator:**
```powershell
# 1. Open Android Device Manager
#    Start-Menu → Android Device Manager

# 2. Launch an emulator

# 3. Check if visible
adb devices

# 4. May need to wait 30+ seconds for emulator to fully boot
```

**If Still Not Working:**
```powershell
# Restart adb daemon
adb kill-server
adb start-server

# Check again
adb devices

# If emulator: try "adb connect 127.0.0.1:5555"
```

---

### Issue 7: `Rebuild APK Failed`

**Symptoms:**
```
Rebuild gagal:
brut.androlib.err.UndefinedResObject: null
```

**Causes:**
1. APK corrupt after decompile
2. Modified files have errors
3. apktool version incompatibility

**Solutions:**

**Option A: Use fresh APK**
```powershell
# Clean old attempts
rm myapp -Recurse -Force
rm patched.apk -Force

# Try again
python apk_patcher.py myapp.apk
```

**Option B: Update apktool**
```powershell
# Check version
apktool --version

# Update (scoop)
scoop update apktool

# Or (chocolatey)
choco upgrade apktool

# Retry
python apk_patcher.py myapp.apk
```

**Option C: Don't modify manually**
```powershell
# If you modified smali files, that can break rebuild
# Better to keep decompiled structure untouched
# Use only high-level modifications via config_helper.py
```

---

### Issue 8: `Signing Failed`

**Symptoms:**
```
Signing dengan jarsigner gagal:
keytool error: java.lang.Exception: ...
```

**Common Causes:**
- Wrong storepass
- Wrong keypass
- Corrupted keystore
- jarsigner not found

**Solutions:**

**Option A: Try with apksigner instead**
```python
# Edit apk_patcher.py: find_signing_tool()
# Force apksigner:
return 'apksigner', shutil.which('apksigner')
```

**Option B: Use correct credentials**
```
Default debug keystore:
- Location: C:\Users\<username>\.android\debug.keystore
- storepass: android
- keypass: android
- keyalias: androiddebugkey
```

**Option C: Recreate keystore**
```powershell
# Delete old
rm $HOME\.android\debug.keystore

# Create new
keytool -genkey -v -keystore $HOME\.android\debug.keystore `
  -keyalias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass android -keypass android `
  -dname "CN=Android Debug,O=Android,C=US"

# Retry signing
python apk_patcher.py myapp.apk
```

---

### Issue 9: `Permission Denied` (Windows)

**Symptoms:**
```
PermissionError: [Errno 13] Permission denied: 'myapp'
```

**Causes:**
- Running without admin
- Folder is read-only
- File is locked

**Solutions:**

**Option A: Run as Administrator**
```powershell
# Right-click PowerShell → Run as Administrator
# Then retry

# Or use Run-As syntax:
Start-Process python -ArgumentList 'apk_patcher.py myapp.apk' -Verb RunAs
```

**Option B: Change folder permissions**
```powershell
# Make folder writable
icacls "myapp" /grant:r "$env:USERNAME:(OI)(CI)F"

# Retry
python apk_patcher.py myapp.apk
```

**Option C: Check file locking**
```powershell
# See if file is in use
Get-Item myapp.apk | Get-Process

# If locked, close app/editor
```

---

### Issue 10: `Out of Disk Space`

**Symptoms:**
```
OSError: [Errno 28] No space left on device
```

**Diagnosis:**
```powershell
# Check free space
Get-Volume

# For specific drive
Get-Volume C
```

**Solution:**
```powershell
# Clean up:
# - Delete temp files
# - Delete old patched APKs
# - Clear Recycle Bin
# - Run Disk Cleanup

# Check again
Get-Volume C

# Retry when there's at least 2GB free
```

---

## ✅ Pre-Flight Checklist

Before running the patcher:

```
Pre-Execution Checklist:
─────────────────────────

Environment:
  ☐ Python 3.7+ installed
  ☐ Java JDK installed (not JRE)
  ☐ apktool in PATH
  ☐ jarsigner in PATH
  ☐ Debug keystore exists

Input:
  ☐ APK file exists and valid
  ☐ APK not already patched
  ☐ APK not corrupt
  ☐ Sufficient disk space (>2GB)

System:
  ☐ Administrator access (if needed)
  ☐ Antivirus not blocking Python/apktool
  ☐ Terminal fresh (no old processes)

Setup Verification:
  ☐ Run: python setup_check.py
  ☐ All checks should pass (green ✓)
```

If all green, you're ready!

---

## 🔧 Advanced Debugging

Enable debug logging:

```python
# In apk_patcher.py, change logging level:

logging.basicConfig(
    level=logging.DEBUG,  # Change from INFO to DEBUG
    ...
)
```

Then run:
```powershell
python apk_patcher.py myapp.apk 2>&1 | Tee-Object debug.log
```

This creates `debug.log` with all output.

---

## 📞 Getting Help

If still stuck:

1. **Check README.md** - Full reference
2. **Run setup_check.py** - Diagnose environment
3. **Check example_usage.py** - See working examples
4. **Search this file** - Ctrl+F to find similar issues
5. **Check online** - Search exact error on StackOverflow/GitHub

**When asking for help, provide:**
```
- Python version: python --version
- OS: Windows 10/11
- Java version: java -version
- apktool version: apktool --version
- Error message: (full traceback)
- APK size and type: (what app is it?)
```

---

## 📚 Reference Links

- [Apktool Documentation](https://ibotpeaches.github.io/Apktool/)
- [Android Network Security Config](https://developer.android.com/training/articles/security-config)
- [Android Studio Emulator](https://developer.android.com/studio/run/emulator)
- [Burp Suite Android Setup](https://portswigger.net/burp/documentation/desktop/mobile/proxy-android)

---

**Last Updated:** 2026-05-25  
**Version:** 1.0

Good luck! 🚀
