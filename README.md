# APK Patcher - SSL Pinning Bypass Tool

Script Python untuk otomatis bypass SSL Pinning pada APK Android. Memungkinkan sniffing traffic dengan Burp Suite, Charles, atau Canary untuk security testing.

## 📋 Fitur

✅ Dekompilasi APK otomatis (`apktool d`)  
✅ Inject `network_security_config.xml` untuk allow user CA  
✅ Modifikasi `AndroidManifest.xml` otomatis  
✅ Rebuild APK otomatis (`apktool b`)  
✅ Sign APK otomatis (apksigner/jarsigner)  
✅ Full error handling & logging  
✅ Windows compatible  

## 🔧 Prerequisites

### 1. Python 3.7+
```powershell
python --version
```

### 2. Java JDK (untuk jarsigner)
```powershell
java -version
```
Download: [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) atau [OpenJDK](https://adoptopenjdk.net/)

### 3. Android SDK Tools (apktool)
Opsi A: Download manual
```powershell
# 1. Download dari: https://ibotpeaches.github.io/Apktool/
# 2. Extract ke: C:\apktool\
# 3. Tambah ke PATH (lihat Step 4)
```

Opsi B: Gunakan package manager
```powershell
# Jika punya scoop
scoop install apktool

# Atau jika punya chocolatey
choco install apktool
```

### 4. Tambah ke Windows PATH

**Via PowerShell (Admin):**
```powershell
# Check current PATH
[Environment]::GetEnvironmentVariable("Path", "User")

# Tambah Java (JDK bin folder)
$binPath = "C:\Program Files\Java\jdk-21.0.1\bin"  # sesuaikan versi
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$binPath", "User")

# Tambah apktool
$apktoolPath = "C:\apktool"  # atau path yang tepat
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$apktoolPath", "User")
```

**Restart PowerShell/Terminal setelah ini**

**Verifikasi:**
```powershell
apktool --version
jarsigner -h
```

### 5. Debug Keystore untuk Signing

Biasanya sudah ada di `C:\Users\<username>\.android\debug.keystore`

Jika belum ada, buat dengan:
```powershell
$keytoolPath = "C:\Program Files\Java\jdk-26.0.1\bin\keytool.exe"  # sesuaikan

& $keytoolPath -genkeypair -v -keystore $HOME\.android\debug.keystore `
  -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
```

## 🚀 Penggunaan

### Basic Usage
```powershell
cd C:\path\to\script
python apk_patcher.py target.apk
```

Output: `patched.apk` (di folder yang sama)

### Custom Output Name
```powershell
python apk_patcher.py target.apk my_patched_app.apk
```

### Contoh Complete Workflow
```powershell
# 1. Navigate ke folder
cd C:\Users\rriat\OneDrive\Dokumen\test\testing

# 2. Copy target APK di sini
copy "C:\path\to\original_app.apk" "target.apk"

# 3. Jalankan patcher
python apk_patcher.py target.apk patched.apk

# 4. Install ke device
adb install patched.apk

# 5. Setup proxy di Android Settings
# Settings > Network & Internet > WiFi > (select network) > Advanced > Proxy > Manual
# Host: <your-computer-ip>
# Port: 8080 (atau sesuai Burp Suite)

# 6. Install Burp Suite CA di Android device (Settings > Security > Install Certificate)
```

## 📊 Output & Logging

Script memberikan detailed logging untuk setiap step:

```
[14:32:05] INFO     - ======================================================================
[14:32:05] INFO     - APK PATCHER - SSL PINNING BYPASS
[14:32:05] INFO     - ======================================================================
[14:32:05] INFO     - 
[14:32:05] INFO     - [STEP 1/5] Dekompilasi APK...
[14:32:05] INFO     - Menjalankan: apktool d target.apk
[14:32:15] INFO     - ✓ Dekompilasi berhasil: target/
[14:32:15] INFO     - 
[14:32:15] INFO     - [STEP 2/5] Membuat network_security_config.xml...
[14:32:15] INFO     - ✓ Network config dibuat: target\res\xml\network_security_config.xml
[14:32:15] INFO     - 
[14:32:15] INFO     - [STEP 3/5] Memodifikasi AndroidManifest.xml...
[14:32:15] INFO     - ✓ Attribute networkSecurityConfig ditambahkan ke <application>
[14:32:15] INFO     - ✓ AndroidManifest.xml dimodifikasi: target\AndroidManifest.xml
[14:32:15] INFO     - 
[14:32:15] INFO     - [STEP 4/5] Rebuild APK...
[14:32:25] INFO     - ✓ APK di-rebuild: patched.apk
[14:32:25] INFO     - 
[14:32:25] INFO     - [STEP 5/5] Sign APK...
[14:32:26] INFO     - Tool signing ditemukan: jarsigner
[14:32:28] INFO     - ✓ APK di-sign dengan jarsigner
[14:32:28] INFO     - 
[14:32:28] INFO     - ======================================================================
[14:32:28] INFO     - ✓ PATCHING BERHASIL!
[14:32:28] INFO     - ======================================================================
[14:32:28] INFO     - Output APK: patched.apk
[14:32:28] INFO     - Instalasi: adb install patched.apk
[14:32:28] INFO     - ======================================================================
```

## 🔍 Network Security Config Dijelaskan

File `network_security_config.xml` yang di-inject:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow user-installed CA certificates for debugging -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">.</domain>
        <trust-anchors>
            <!-- User CA certificates -->
            <certificates src="user" />
            <!-- System CA certificates -->
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
</network-security-config>
```

**Penjelasan:**
- `cleartext­TrafficPermitted="true"`: Allow HTTP (tidak hanya HTTPS)
- `certificates src="user"`: Trust user-installed CA (Burp, Charles, Canary)
- `certificates src="system"`: Tetap trust sistem certificate
- `domain includeSubdomains="true"`: Apply ke semua domain
- `.` = all domains

## 📝 AndroidManifest.xml Modification

Script menambahkan:
```xml
<application
    ...
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

Ini membuat OS Android menggunakan config yang kita buat.

## ❌ Troubleshooting

### Error: "apktool tidak ditemukan di PATH"
```powershell
# Verifikasi instalasi
apktool --version

# Jika error, tambah ke PATH atau gunakan full path
python apk_patcher.py target.apk

# Alternative: sesuaikan PATH via PowerShell Admin
```

### Error: "Debug keystore tidak ditemukan"
```powershell
# Buat debug keystore
keytool -genkey -v -keystore $HOME\.android\debug.keystore `
  -keyalias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
```

### Error: "Dekompilasi gagal"
- APK sudah rusak/corrupt → gunakan APK lain
- Versi apktool lama → update ke latest
- Izin file → run PowerShell as Admin

### Error: "XML Parse error"
- AndroidManifest.xml sudah dimodifikasi → clean dan mulai lagi
- Format XML corrupt → gunakan APK original baru

### APK gagal install
- APK tidak signed → script otomatis sign
- Berbeda architecture (arm64 vs armv7) → sesuaikan device
- Version mismatch → uninstall versi lama dulu
```powershell
adb uninstall com.example.app
adb install patched.apk
```

## 🛡️ Security Notes

**Disclaimer:**
- Script ini untuk authorized security testing HANYA
- Gunakan pada APK yang Anda buat atau punya izin
- Illegal usage adalah tanggung jawab user
- Anda bertanggung jawab atas penggunaan

**Best Practice:**
- Test di Android emulator/device testing terlebih dahulu
- Jangan share patched APK ke pihak lain
- Hapus patched APK setelah testing selesai

## 📚 API Reference

### Fungsi Utama
```python
patch_apk(apk_path, output_apk='patched.apk', cleanup=True) -> str
```

### Fungsi Tersegmentasi
```python
decompile_apk(apk_path) -> str
create_network_security_config(output_dir) -> Path
modify_android_manifest(output_dir) -> None
rebuild_apk(output_dir, output_apk) -> str
sign_apk(apk_path) -> None
```

## 📦 Dependencies

Only built-in Python modules:
- `subprocess` - Execute system commands
- `xml.etree.ElementTree` - XML parsing & modification
- `pathlib` - File path operations
- `logging` - Detailed logging
- `shutil` - File operations

Tidak perlu `pip install` apapun!

## 🔗 Useful Resources

- [Apktool Documentation](https://ibotpeaches.github.io/Apktool/)
- [Android Network Security Config](https://developer.android.com/training/articles/security-config)
- [Burp Suite for Android](https://portswigger.net/burp/documentation/desktop/mobile/proxy-android)
- [Jarsigner Docs](https://docs.oracle.com/javase/tutorial/security/toolfilex/rstep2.html)

## 📄 License

For authorized security testing only.

---

**Questions?** Check the script's docstrings untuk detailed parameter explanation.
#   r e v e r s e - t o k p e d  
 