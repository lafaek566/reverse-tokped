# APK Patcher - Project Manifest

Manifest file yang menjelaskan struktur dan komposisi project APK Patcher.

## 📂 Project Structure

```
testing/
├── 🔧 MAIN TOOLS
│   ├── apk_patcher.py              Main patcher script (472 lines)
│   ├── setup_check.py              Environment validator (270 lines)
│   ├── config_helper.py            Advanced customization module (330 lines)
│   ├── example_usage.py            Usage examples & workflows (340 lines)
│   └── run.bat                     Windows GUI batch runner
│
├── 📖 DOCUMENTATION
│   ├── INDEX.md                    Project overview & navigation (THIS IS START POINT)
│   ├── QUICKSTART.md               5-minute quick start guide
│   ├── README.md                   Full reference documentation
│   ├── DEVELOPER_GUIDE.md          Architecture & API reference
│   ├── TROUBLESHOOTING.md          Issues & solutions (10 common problems)
│   ├── PROJECT_MANIFEST.md         This file
│   └── PROJECT_MANIFEST.txt        Text version of this file
│
└── 📦 Generated Files (after running)
    ├── [appname]/                  Decompiled APK folder
    ├── patched.apk                 Output patched APK
    ├── debug.keystore              Android debug signing key
    └── *.log                       Execution logs (if any)
```

## 📋 File Descriptions

### 🔧 Core Tools

#### 1. apk_patcher.py (472 lines)
**The Main Tool** - Orchestrates entire SSL Pinning bypass process.

**What it does:**
- Step 1: Dekompilasi APK via `apktool d`
- Step 2: Buat network_security_config.xml
- Step 3: Modifikasi AndroidManifest.xml
- Step 4: Rebuild APK via `apktool b`
- Step 5: Sign APK dengan jarsigner/apksigner

**Key Functions:**
- `patch_apk()` - Main entry point
- `decompile_apk()` - APK decompilation
- `create_network_security_config()` - XML injection
- `modify_android_manifest()` - Manifest modification
- `rebuild_apk()` - APK building
- `sign_apk()` - APK signing
- `run_command()` - Shell command executor
- `check_tool_exists()` - Tool availability checker
- `validate_paths()` - Input validation

**Dependencies:**
- subprocess, pathlib, logging, xml.etree.ElementTree (Python stdlib)
- External: apktool, Java JDK, jarsigner

**Usage:**
```bash
python apk_patcher.py target.apk [output.apk]
```

---

#### 2. setup_check.py (270 lines)
**Environment Validator** - Verifies all prerequisites are installed.

**What it checks:**
- Python 3.7+ ✓
- Java JDK ✓
- jarsigner ✓
- apktool ✓
- Debug keystore ✓

**Auto-creates:**
- ~/.android/debug.keystore (if missing)

**Output:**
- Color-coded results
- Helpful error messages
- Installation instructions

**Usage:**
```bash
python setup_check.py
```

---

#### 3. config_helper.py (330 lines)
**Advanced Customization Module** - Helper classes for custom modifications.

**Modules:**
```
StringsXMLModifier      - Modify app strings
PermissionModifier      - Add/list permissions
ResourceModifier        - Work with resources
BuildPropertiesModifier - Modify build properties
ConfigTemplates         - Predefined configs
NetworkConfigGenerator  - Custom network configs
```

**Use Case:**
```python
from config_helper import StringsXMLModifier
StringsXMLModifier.modify_strings('decompiled_app', {
    'api_url': 'https://debug.example.com'
})
```

---

#### 4. example_usage.py (340 lines)
**Usage Examples & Workflows** - Interactive menu with 7 examples.

**Examples:**
1. Simple patching
2. Custom output name
3. Manual step-by-step (advanced)
4. Batch processing
5. Advanced error handling
6. Security testing workflow
7. Troubleshooting guide

**Usage:**
```bash
python example_usage.py
# Interactive menu appears
```

---

#### 5. run.bat
**Windows GUI Runner** - Convenience batch script for Windows users.

**Features:**
- Menu-driven interface
- File exists checks
- Error handling
- Integrated with example_usage.py
- Opens README.md

**Usage:**
```
Double-click: run.bat
```

---

### 📖 Documentation Files

#### 1. INDEX.md ⭐ START HERE
**Project Overview & Navigation Guide**
- File overview table
- Quick navigation by use case
- Step-by-step scenarios
- Workflow diagram
- Quick troubleshooting table

**When to read:** First time / confused where to start

---

#### 2. QUICKSTART.md
**5-Minute Quick Start**
- Prerequisites (2 commands)
- Basic usage (2 commands)
- Install to device
- Setup Burp Suite
- Verification checklist
- Pro tips

**When to read:** Want to start immediately

**Length:** ~5 minutes reading + 5 minutes setup

---

#### 3. README.md
**Full Reference Documentation**
- Complete prerequisites (detailed)
- Usage examples
- Network Security Config explained
- AndroidManifest.xml modification details
- Extensive troubleshooting
- Useful resources

**When to read:** Need comprehensive understanding

**Length:** ~30 minutes reading

---

#### 4. DEVELOPER_GUIDE.md
**Architecture & API Reference**
- Architecture overview with diagrams
- Complete API reference (12 functions)
- Customization options (4 levels)
- Error handling guide
- Performance optimization
- Common modifications list

**When to read:** Want to extend/customize script

**Length:** ~40 minutes reading

---

#### 5. TROUBLESHOOTING.md
**Common Issues & Solutions**
- Diagnostic commands
- 10 detailed issue categories
- Pre-flight checklist
- Advanced debugging tips
- Reference links

**Issues covered:**
1. apktool not found
2. jarsigner not found
3. Debug keystore missing
4. XML Parse Error
5. APK Installation Failed
6. Device Not Found
7. Rebuild Failed
8. Signing Failed
9. Permission Denied
10. Out of Disk Space

**When to read:** When something goes wrong

**Length:** ~20 minutes to find your issue + solution time

---

#### 6. PROJECT_MANIFEST.md (This File)
**Project Structure & File Descriptions**
- Detailed file breakdown
- Dependencies matrix
- Quick reference table
- Getting started flow

---

## 🔄 Dependencies Matrix

### External Tools Required

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| apktool | Latest | APK decompile/repack | scoop/choco/manual |
| Java JDK | 11+ | jarsigner runtime | oracle/openjdk |
| Python | 3.7+ | Script runtime | python.org |
| ADB | Latest | Device installation | Android SDK |

### Python Dependencies

All built-in (no `pip install` needed):
- subprocess (shell commands)
- pathlib (file paths)
- xml.etree.ElementTree (XML parsing)
- logging (logging output)
- shutil (file operations)
- winreg (Windows registry - setup_check.py)

### System Requirements

**Windows:**
- OS: Windows 7+
- RAM: 2GB minimum
- Disk: 10GB free (for APK decompilation)
- Admin access (for some tools)

**Mac/Linux:**
- Similar to Windows
- PATH configuration different
- Use brew/apt instead of choco

---

## 🎯 Getting Started Flow

```
┌──────────────────────────────────────────┐
│   Start Here: Read this FILE             │
│   (INDEX.md - this one)                  │
└────────────────┬─────────────────────────┘
                 │
         ┌───────┴────────┬──────────┐
         │                │          │
         ▼                ▼          ▼
    [Quick?]      [Setup needed?] [Issue?]
       │                │           │
    QUICKSTART.md   setup_check.py TROUBLESHOOTING.md
       │                │           │
       ▼                ▼           ▼
    [READY!]       ✓ All good    [FIXED?]
       │                │          │
       └────────┬───────┘          │
                ▼                  │
         python apk_patcher.py     │
          target.apk               │
                │                  │
         ┌──────┴──────┐           │
         ▼             ▼           │
    [Success?]   [Error?]──────────┘
         │             │
         ▼             ▼
    adb install   See error msg
    patched.apk   → TROUBLESHOOTING.md
         │
         ▼
    Done! Open Burp Suite
    and intercept traffic
```

---

## 📊 Code Statistics

```
Total Lines of Code:
  apk_patcher.py ........... 472
  setup_check.py ........... 270
  config_helper.py ......... 330
  example_usage.py ......... 340
  ────────────────────────────
  Total ................... 1,412

Total Documentation:
  README.md ................ 650
  QUICKSTART.md ............ 350
  DEVELOPER_GUIDE.md ....... 500
  TROUBLESHOOTING.md ....... 750
  INDEX.md ................. 450
  PROJECT_MANIFEST.md ...... 350
  ────────────────────────────
  Total ................... 3,050

Total Project Size: ~1,400 lines code + 3,000 lines docs

All Python code:
  - No external dependencies (all stdlib)
  - Well-commented
  - Modular design
  - Error handling throughout
  - Type hints where helpful
```

---

## ✅ Feature Checklist

Core Features:
- [x] Automated APK decompilation
- [x] SSL Pinning bypass (network_security_config.xml)
- [x] AndroidManifest.xml modification
- [x] Automated APK rebuilding
- [x] Automated APK signing
- [x] Error handling & logging
- [x] Cross-platform support

Supporting Features:
- [x] Environment validation (setup_check.py)
- [x] Advanced customization (config_helper.py)
- [x] Usage examples (example_usage.py)
- [x] Windows GUI (run.bat)
- [x] Interactive menu

Documentation:
- [x] Quick start guide
- [x] Full reference guide
- [x] API documentation
- [x] Architecture guide
- [x] Troubleshooting guide
- [x] Project manifest
- [x] Example workflows

---

## 🔐 Security Considerations

**What Data Is Used:**
- APK file contents (decompilation)
- System environment (PATH, JAVA_HOME)
- Debug keystore credentials (stored locally)

**What Data Is Generated:**
- Decompiled folder (temporary)
- Patched APK (your output)
- Log files (execution logs)

**Best Practices:**
- Use on test devices only
- Don't share patched APKs
- Keep debug.keystore private
- Test in isolated environments
- Use for authorized testing only

---

## 🆘 Quick Help

**Lost?** → Start with INDEX.md (this file)  
**Want quick start?** → QUICKSTART.md  
**Having issues?** → TROUBLESHOOTING.md  
**Want to code?** → DEVELOPER_GUIDE.md  
**Need full reference?** → README.md  
**Want examples?** → python example_usage.py  

---

## 🔗 File Cross-References

```
Beginner Path:
  INDEX.md → QUICKSTART.md → README.md

Troubleshooting Path:
  Any error → TROUBLESHOOTING.md → Diagnostic command

Development Path:
  DEVELOPER_GUIDE.md → config_helper.py → example_usage.py

Reference Path:
  README.md → DEVELOPER_GUIDE.md → TROUBLESHOOTING.md
```

---

## 📝 Notes

**Version:** 1.0  
**Last Updated:** 2026-05-25  
**Status:** Complete & Production Ready  
**License:** For authorized security testing only  

**Package Includes:**
- 5 Python scripts (1,412 lines)
- 6 Documentation files (3,050 lines)
- 1 Batch runner (for Windows)
- Total: ~4,500 lines of code & docs

**What's Covered:**
- ✓ Complete SSL Pinning bypass automation
- ✓ Environment setup & validation
- ✓ Advanced customization options
- ✓ Comprehensive documentation
- ✓ Extensive troubleshooting
- ✓ Usage examples & workflows
- ✓ Windows batch GUI
- ✓ Developer API reference

---

## 🚀 Quick Start (5 min)

1. Read: QUICKSTART.md
2. Run: python setup_check.py
3. Execute: python apk_patcher.py target.apk
4. Install: adb install patched.apk
5. Done!

---

**Questions?** Check INDEX.md → Find your scenario → Read relevant docs  
**Ready?** Run: `python setup_check.py` → `python apk_patcher.py target.apk`

Good luck! 🎯
