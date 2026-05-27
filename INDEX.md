# APK Patcher - Complete Package Index

Dokumentasi lengkap untuk SSL Pinning bypass automation di Android APK.

## 📦 File Overview

Berikut file-file yang termasuk dalam package:

### 🔧 Main Scripts

| File | Purpose |
|------|---------|
| **apk_patcher.py** | **THE MAIN TOOL** - Core APK patcher script. Lakukan semua 5 steps otomatis |
| **setup_check.py** | Environment validator - verify Python, Java, apktool, jarsigner installed |
| **config_helper.py** | Advanced customization module - add custom modifications |
| **example_usage.py** | Usage examples - interactive menu dengan berbagai use cases |
| **run.bat** | Windows batch runner - GUI menu untuk Windows users |

### 📖 Documentation

| File | Purpose |
|------|---------|
| **README.md** | Full reference documentation - lengkap tapi detailed |
| **QUICKSTART.md** | Quick start guide - untuk yang ingin langsung pakai (5 minutes) |
| **DEVELOPER_GUIDE.md** | Architecture & API reference - untuk developers yang ingin extend |
| **TROUBLESHOOTING.md** | Common issues & solutions - lengkap dengan diagnostics |
| **INDEX.md** | This file - overview dan navigation guide |

---

## 🚀 Quick Navigation

### "Saya ingin cepat pakai sekarang!"
```
1. Baca: QUICKSTART.md (5 min)
2. Setup: Jalankan setup_check.py
3. Run: python apk_patcher.py target.apk
4. Done! File output: patched.apk
```

### "Saya butuh panduan lengkap"
```
1. Baca: README.md (30 min)
2. Cek: QUICKSTART.md untuk quick setup
3. Jalankan: example_usage.py untuk lihat examples
4. Troubleshoot: TROUBLESHOOTING.md jika ada masalah
```

### "Saya developer, mau extend script"
```
1. Baca: DEVELOPER_GUIDE.md (architecture & API)
2. Check: config_helper.py untuk customization hooks
3. Lihat: example_usage.py EXAMPLE 3 (manual steps)
4. Code: Mulai develop custom modifications
```

### "Saya di Windows dan ingin GUI"
```
1. Double-click: run.bat
2. Pilih menu option
3. Ikuti prompts
4. Done!
```

### "Ada error, gimana?"
```
1. Jalankan: python setup_check.py
2. Lihat hasilnya - apa yang missing?
3. Baca: TROUBLESHOOTING.md - cari error Anda
4. Follow solution steps
```

---

## 📋 Step-by-Step Usage

### Scenario A: Simple Patching (Beginner)

```bash
# 1. Place your APK in same folder
copy "C:\path\to\your_app.apk" "target.apk"

# 2. Run patcher
python apk_patcher.py target.apk

# 3. Install to device
adb install patched.apk

# Done! Now you can intercept traffic in Burp Suite
```

### Scenario B: Custom Output + Keep Files (Intermediate)

```bash
# 1. Run with custom output name
python apk_patcher.py myapp.apk myapp_ssl_bypass.apk

# 2. Decompiled folder "myapp/" is kept for analysis
# 3. Check modifications in: myapp/res/xml/network_security_config.xml
# 4. Check manifest: myapp/AndroidManifest.xml

# 5. Install
adb install myapp_ssl_bypass.apk
```

### Scenario C: Manual Control + Custom Modifications (Advanced)

```bash
# Run example_usage.py EXAMPLE 3
python example_usage.py

# Select option 3: Manual Step-by-Step
# This shows how to:
# - Decompile
# - Modify network config
# - Add custom changes (e.g., remove analytics)
# - Rebuild & sign

# Then use in your own code:
from apk_patcher import *
from config_helper import StringsXMLModifier

decompiled = decompile_apk('app.apk')
create_network_security_config(decompiled)
modify_android_manifest(decompiled)

# Custom: Change API endpoint
StringsXMLModifier.modify_strings(decompiled, {
    'api_url': 'https://debug.example.com'
})

rebuilt = rebuild_apk(decompiled)
sign_apk(rebuilt)
```

---

## 🔄 Workflow Diagram

```
┌─────────────────────────────────────────┐
│  Your Original APK (target.apk)         │
│  - Has SSL pinning enabled              │
│  - Cannot intercept traffic             │
└──────────────┬──────────────────────────┘
               │
               ▼
        [apk_patcher.py]
               │
        ┌──────┴──────┐
        ▼             ▼
    [Step 1-5]   [Auto process]
      Manual      - Decompile
      control     - Inject config
      available   - Modify manifest
      via         - Rebuild
      config_     - Sign
      helper.py
        │
        ▼
┌─────────────────────────────────────┐
│  Patched APK (patched.apk)          │
│  - SSL pinning disabled             │
│  - User CA certificates accepted    │
│  - Ready for interception           │
└─────────────────────────────────────┘
        │
        ▼
    [adb install]
        │
        ▼
┌─────────────────────────────────────┐
│  Device/Emulator                    │
│  - App running with bypass          │
│  - Ready for Burp Suite sniffing   │
└─────────────────────────────────────┘
        │
        ▼
    [Burp Suite / Charles / Canary]
        │
        ▼
        API Endpoints Visible & Modifiable!
```

---

## 🎯 File Dependencies

```
apk_patcher.py
├─ Uses: subprocess (Python stdlib)
├─ Uses: xml.etree.ElementTree (Python stdlib)
├─ Uses: pathlib (Python stdlib)
├─ Requires external: apktool
├─ Requires external: jarsigner (Java)
└─ Requires: debug.keystore (~/.android/)

config_helper.py (optional)
├─ Extends: apk_patcher.py
├─ Provides: StringsXMLModifier, PermissionModifier, etc
└─ Used by: Advanced users only

example_usage.py
├─ Imports: apk_patcher
├─ Imports: config_helper
└─ For: Learning & examples

setup_check.py
├─ Standalone validator
├─ Can create debug.keystore
└─ For: Environment verification

run.bat (Windows only)
└─ GUI wrapper around apk_patcher.py
```

---

## ✅ Before You Start

**Prerequisites Checklist:**

- [ ] **Python 3.7+** → `python --version`
- [ ] **Java JDK** → `java -version` (NOT just JRE)
- [ ] **apktool** → `apktool --version`
- [ ] **jarsigner** → `jarsigner -help`
- [ ] **2GB+ Disk Space** for decompilation
- [ ] **Android device/emulator** for testing
- [ ] **ADB installed** → `adb version`
- [ ] **Burp Suite** (or Charles/Canary) for interception

**Setup Command:**
```bash
python setup_check.py
# Will verify all above and create debug.keystore if needed
```

---

## 🆘 Quick Troubleshooting

| Error | Fix |
|-------|-----|
| `apktool not found` | See: TROUBLESHOOTING.md → Issue 1 |
| `jarsigner not found` | See: TROUBLESHOOTING.md → Issue 2 |
| `Debug keystore not found` | Run: `setup_check.py` (automatic create) |
| `XML Parse error` | Use fresh APK (not already patched) |
| `APK install fails` | See: TROUBLESHOOTING.md → Issue 5 |
| `Permission denied` | Run as Administrator |

---

## 📚 Documentation Structure

```
README.md
├─ Setup & prerequisites (Windows)
├─ Basic usage with examples
├─ Understanding network_security_config.xml
└─ Useful resources & links

QUICKSTART.md
├─ 5 minute quick setup
├─ 2-command basic usage
├─ Common scenarios
└─ Pro tips

DEVELOPER_GUIDE.md
├─ Architecture overview
├─ Complete API reference
├─ Customization options (4 levels)
├─ Error handling guide
└─ Performance optimization

TROUBLESHOOTING.md
├─ Diagnostic commands
├─ 10 common issues + solutions
├─ Pre-flight checklist
├─ Advanced debugging
└─ Reference links

This INDEX.md
├─ File overview
├─ Quick navigation
├─ Step-by-step scenarios
└─ Quick reference
```

**Start Point Recommendation:**
1. First time? → QUICKSTART.md
2. Having issues? → TROUBLESHOOTING.md
3. Want to customize? → DEVELOPER_GUIDE.md + config_helper.py
4. Need reference? → README.md

---

## 🔐 Security & Legal Notes

**What This Tool Does:**
✅ Allows intercepting HTTPS traffic for authorized testing  
✅ Disables SSL pinning for development/debugging  
✅ Enables security research on Android apps  

**Authorized Use Only:**
⚠️ Use only on apps you own or have explicit permission to test  
⚠️ For authorized penetration testing only  
⚠️ Respect app developers' terms of service  
⚠️ Don't share patched APKs publicly  

**Compliance:**
- Test only in controlled environments
- Document all testing activities
- Use for learning and security improvement
- Share findings responsibly

---

## 💡 Common Use Cases

### Use Case 1: API Reverse Engineering
```
1. Patch APK
2. Install on emulator/device
3. Intercept traffic in Burp Suite
4. Map all API endpoints
5. Document endpoints, methods, parameters
```

### Use Case 2: Security Testing
```
1. Patch APK
2. Modify requests in Burp/Charles
3. Test for: SQL injection, auth bypass, etc
4. Document vulnerabilities
5. Report to app developers
```

### Use Case 3: Development/Debugging
```
1. Patch your own app APK
2. Debug API calls during development
3. Test different API responses
4. Validate SSL certificate handling
```

### Use Case 4: Learning & Training
```
1. Study how Android apps communicate
2. Understand REST API patterns
3. Learn security concepts
4. Build similar apps with better security
```

---

## 📞 Support Resources

### Official Documentation
- [Android Developer Docs](https://developer.android.com/)
- [Apktool GitHub](https://github.com/iBotPeaches/Apktool)
- [Network Security Config](https://developer.android.com/training/articles/security-config)

### Security Tools
- [Burp Suite Community](https://portswigger.net/burp/community)
- [Charles Proxy](https://www.charlesproxy.com/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

### Learning Resources
- Android reverse engineering courses
- Mobile security testing guides
- API security best practices

---

## 📊 Feature Comparison

| Feature | Capability |
|---------|-----------|
| APK Decompilation | ✅ Fully automated |
| SSL Pinning Bypass | ✅ Complete |
| Manifest Modification | ✅ Automatic |
| Custom Modifications | ✅ Via config_helper.py |
| APK Rebuilding | ✅ Fully automated |
| APK Signing | ✅ Auto-detect jarsigner/apksigner |
| Error Handling | ✅ Comprehensive |
| Logging | ✅ Detailed output |
| Cross-platform | ✅ Windows/Mac/Linux |
| GUI Interface | ✅ run.bat (Windows) |
| Batch Processing | ✅ Via example_usage.py |

---

## 🎓 Next Steps

1. **First Time?**
   - Read: QUICKSTART.md (5 min)
   - Run: python setup_check.py
   - Execute: python apk_patcher.py target.apk

2. **Having Issues?**
   - Check: TROUBLESHOOTING.md
   - Run: python setup_check.py (diagnose)
   - Read: README.md (detailed setup)

3. **Want to Customize?**
   - Read: DEVELOPER_GUIDE.md
   - Study: config_helper.py
   - Try: example_usage.py EXAMPLE 3 (manual control)

4. **Ready for Production?**
   - Understand: Network security model
   - Review: All modifications in decompiled folder
   - Test: On emulator/test device first
   - Document: All changes made

---

## 📝 Changelog

**Version 1.0** (2026-05-25)
- Initial release
- Complete SSL pinning bypass implementation
- Full documentation suite
- Windows batch GUI
- Comprehensive error handling
- Example workflows
- Helper modules for customization

---

## 🙏 Credits

Built for authorized security testing and development.

For questions or improvements, refer to the documentation files.

---

**🚀 Ready to get started?**

Choose your path:
- **Quick Start**: QUICKSTART.md
- **Full Setup**: README.md
- **Troubleshooting**: TROUBLESHOOTING.md
- **Development**: DEVELOPER_GUIDE.md
- **Examples**: python example_usage.py

---

**Last Updated:** 2026-05-25  
**Version:** 1.0  
**License:** For authorized security testing only

Good luck! Happy reversing! 🔍
