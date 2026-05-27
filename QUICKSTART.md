# APK Patcher - Quick Start Guide

Panduan cepat untuk langsung menggunakan script SSL Pinning bypass.

## ⚡ 5 Menit Quick Setup (Windows)

### 1. Install Java JDK
```powershell
# Download dari:
# https://www.oracle.com/java/technologies/downloads/

# Atau gunakan Chocolatey:
choco install openjdk
```

### 2. Install Apktool
```powershell
# Option A: Using scoop
scoop install apktool

# Option B: Using Chocolatey  
choco install apktool

# Option C: Manual
# - Download dari https://ibotpeaches.github.io/Apktool/
# - Extract ke C:\apktool
# - Add C:\apktool ke Windows PATH
```

### 3. Verifikasi Installation
```powershell
# Buka PowerShell/Command Prompt baru dan jalankan:
java -version      # Harus show Java version
apktool --version  # Harus show apktool version
jarsigner -help    # Harus show jarsigner help
```

Jika ada yang not found, baca troubleshooting di bawah.

### 4. Run Setup Checker (Optional)
```powershell
python setup_check.py
```

---

## 🚀 Basic Usage (2 Commands)

### Copy file ke folder script:
```powershell
# Windows File Explorer atau Command Prompt
copy "C:\path\to\your_app.apk" "target.apk"
```

### Jalankan patcher:
```powershell
python apk_patcher.py target.apk
```

### Done! Output:
```powershell
# File baru: patched.apk (ready to install)
adb install patched.apk
```

---

## 📱 Install ke Device

### Via ADB (connected device):
```powershell
# Uninstall old version (if any)
adb uninstall com.example.app

# Install patched APK
adb install patched.apk

# Verify
adb shell pm list packages | findstr example
```

### Via Android Studio (emulator):
```
1. Open Android Device Manager
2. Select emulator
3. Drag & drop patched.apk ke emulator
4. Done
```

---

## 🔧 Setup Burp Suite untuk Sniffing

### On Your Computer:
```
1. Open Burp Suite
2. Go to Proxy Settings → Listeners
3. Set Host: 0.0.0.0, Port: 8080
4. Export CA Certificate:
   → Proxy → Options → CA Certificate → Save
```

### On Android Device:
```
1. Get your computer IP:
   PowerShell: ipconfig (Look for "IPv4 Address")

2. On Android Settings:
   → WiFi → Select Network → Advanced
   → Proxy: Manual
   → Host: <your-computer-ip>
   → Port: 8080
   → Save

3. Install Burp CA:
   → Settings → Security → Install from SD Card
   → Select exported certificate
```

---

## 🎯 Common Usage Scenarios

### Scenario 1: Basic API Analysis
```powershell
# 1. Patch
python apk_patcher.py facebook.apk facebook_patched.apk

# 2. Install
adb install facebook_patched.apk

# 3. Open app, check Burp Suite for traffic
```

### Scenario 2: Custom Output Name
```powershell
python apk_patcher.py shopping_app.apk shopping_app_ssl_bypass.apk
```

### Scenario 3: Keep Decompiled Files (untuk manual modifications)
```powershell
# Edit apk_patcher.py line:
# patch_apk('target.apk', cleanup=False)

# Maka folder decompile akan di-keep untuk analysis
```

---

## ✅ Verification Checklist

- [ ] Java installed: `java -version`
- [ ] Apktool installed: `apktool --version`
- [ ] Jarsigner accessible: `jarsigner -help`
- [ ] Python 3.7+: `python --version`
- [ ] APK file ready in script folder
- [ ] ADB installed (Android SDK): `adb version`
- [ ] Device connected: `adb devices`

---

## ❌ Quick Troubleshooting

| Error | Solution |
|-------|----------|
| `apktool: command not found` | Add C:\apktool to Windows PATH |
| `jarsigner: command not found` | Add Java JDK bin folder to PATH |
| `Debug keystore not found` | Run `setup_check.py` to create |
| `APK install fails` | Run `adb uninstall <package>` first |
| `XML Parse error` | Use fresh APK, not already patched |

---

## 📋 File Explanations

| File | Purpose |
|------|---------|
| `apk_patcher.py` | Main script - THE TOOL |
| `setup_check.py` | Verify installation |
| `example_usage.py` | Usage examples & scenarios |
| `README.md` | Full documentation |
| `QUICKSTART.md` | This file |

---

## 🔗 Useful Commands

```powershell
# List installed packages
adb shell pm list packages

# Check app logs real-time
adb logcat | findstr "app-name"

# Push file to device
adb push file.txt /sdcard/

# Pull file from device
adb pull /sdcard/file.txt .

# Open app
adb shell am start -n com.example.app/.MainActivity

# Check device info
adb shell getprop ro.build.version.release
```

---

## 📞 Still Having Issues?

1. **Check README.md** - Full troubleshooting guide
2. **Run setup_check.py** - Verify environment
3. **Check internet** - Some tools need to download
4. **Restart terminal** - After changing PATH
5. **Run as Admin** - Some tools need elevated privileges

---

## ⚡ Pro Tips

- **Keep original APK backup** - Don't overwrite
- **Test with emulator first** - Before real device
- **Clear app data after patching** - Settings → Apps → Storage → Clear
- **Use Burp Suite Pro** - More features than Community
- **Check Charles Proxy** - Alternative to Burp (also works)

---

## 🛡️ Remember

✓ Use only on APKs you own or have permission to test  
✓ For authorized penetration testing only  
✓ Don't share patched APKs publicly  
✓ Respect app developers' terms of service  

---

**Ready?** → `python apk_patcher.py target.apk` 🚀
