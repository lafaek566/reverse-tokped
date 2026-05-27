# TOKOPEDIA LITE - REVERSE ENGINEERING PROJECT SOP

Complete Standard Operating Procedure untuk Reverse Engineering & SSL Pinning Bypass
Tokopedia Lite menggunakan APK Patcher Tool

---

## 📋 Project Overview

**Objective:** Melakukan reverse engineering pada aplikasi Tokopedia Lite untuk:
- Menganalisis API endpoints yang digunakan
- Memahami request/response structure
- Mengidentifikasi authentication mechanism
- Capture traffic untuk documentation

**Tools:** APK Patcher (Python) + Burp Suite / Charles Proxy
**Duration:** 7 hari maksimal
**Deliverables:** Patched APK + Traffic logs + API documentation

---

## 📦 Phase 1: Environment Setup (Day 1)

### 1.1 Verify All Tools

```powershell
cd C:\Users\rriat\OneDrive\Dokumen\test\testing

# Run environment checker
py -3 setup_check.py

# Expected output: All ✓ green
```

**Tools yang perlu:**
- ✓ Python 3.7+
- ✓ Java JDK 17+
- ✓ jarsigner (comes with JDK)
- ✓ apktool 2.11.1
- ✓ Debug keystore (auto-created)

### 1.2 Get Tokopedia Lite APK

**Option A: Manual Download**
```
1. Go to: https://apkpure.com/tokopedia-lite/
2. Click "Download APK"
3. Save as: tokopedia-lite.apk
4. Place in: testing folder
```

**Option B: Extract from Device (if have Android device)**
```powershell
# Connect device via USB
adb devices

# Pull APK from device
adb pull /data/app/com.tokopedia.lite/base.apk tokopedia-lite.apk
```

**Option C: From APKMirror**
```
1. Go to: https://www.apkmirror.com/
2. Search: "Tokopedia Lite"
3. Download latest APK
4. Save as: tokopedia-lite.apk
```

### 1.3 Setup Burp Suite

```
1. Download: https://portswigger.net/burp/community/download
2. Install & Open Burp Suite
3. Go to Proxy → Options
4. Listener: 0.0.0.0:8080 (or custom port)
5. Enable "Support invisible proxying"
6. Export CA Certificate (for device installation)
```

---

## 🔧 Phase 2: APK Patching (Day 2)

### 2.1 Patch APK dengan SSL Pinning Bypass

```powershell
cd C:\Users\rriat\OneDrive\Dokumen\test\testing

# Run patcher
py -3 apk_patcher.py tokopedia-lite.apk tokopedia-lite-patched.apk

# Expected output:
# [STEP 1/5] Dekompilasi APK... ✓
# [STEP 2/5] Membuat network_security_config.xml... ✓
# [STEP 3/5] Memodifikasi AndroidManifest.xml... ✓
# [STEP 4/5] Rebuild APK... ✓
# [STEP 5/5] Sign APK... ✓
# Output: tokopedia-lite-patched.apk
```

**What happened:**
1. ✓ Decompiled APK struktur
2. ✓ Created `network_security_config.xml` (allow user CA)
3. ✓ Modified `AndroidManifest.xml` (added networkSecurityConfig)
4. ✓ Rebuilt APK
5. ✓ Signed with debug keystore

### 2.2 Verify Patched APK

```powershell
# Check file exists & size
Get-Item tokopedia-lite-patched.apk

# Expected: ~25-50 MB depending on version
```

---

## 📱 Phase 3: Device Setup (Day 2-3)

### 3.1 Option A: Android Emulator (Recommended for testing)

```powershell
# Open Android Device Manager
# Start an emulator (API 30+, arm64 recommended)

# Verify emulator running
adb devices

# Expected output:
# List of attached devices
# emulator-5554    device
```

### 3.2 Option B: Physical Device

```powershell
# Connect via USB cable

# Enable USB Debugging:
# Settings → About Phone → Build Number (tap 7x)
# Settings → Developer Options → USB Debugging → ON

# Verify connection
adb devices

# Grant permission when prompt appears on device
```

### 3.3 Install Burp Suite CA Certificate

**On Android Device:**
```
1. Open browser → Navigate to: http://burp
   (or http://<your-computer-ip>:8080)
2. Download CA Certificate
3. Settings → Security → Advanced → Install from Storage
4. Select downloaded certificate
5. Trust the certificate
```

### 3.4 Setup Proxy on Device

**WiFi Proxy Configuration:**
```
Settings → WiFi → Select your network → Modify network → Advanced

Proxy: Manual
- Hostname: <Your Computer IP>
  (Find via: ipconfig → IPv4 Address)
- Port: 8080 (or your Burp port)

Save and connect
```

---

## 🔍 Phase 4: Install Patched APK (Day 3)

### 4.1 Uninstall Original (if installed)

```powershell
adb uninstall com.tokopedia.lite
```

### 4.2 Install Patched APK

```powershell
adb install tokopedia-lite-patched.apk

# Wait for completion
# Expected: Success
```

### 4.3 Verify Installation

```powershell
adb shell pm list packages | findstr tokopedia

# Expected output:
# com.tokopedia.lite
```

---

## 🎯 Phase 5: Capture & Analyze Traffic (Day 4-5)

### 5.1 Start Burp Suite Intercepting

**In Burp Suite:**
1. Go to: Proxy → Intercept
2. Button: "Intercept is ON"
3. Go to: Proxy → HTTP history (for logging)

### 5.2 Interact dengan App

**On Android Device, perform these actions:**
1. Open Tokopedia Lite app
2. Browse home page
3. Search for products (e.g., "laptop")
4. Click on product details
5. Go to user profile/account
6. Look at wishlist/saved items
7. Try checkout flow (don't complete)
8. Scroll through different sections

**Watch Burp capture all requests!**

### 5.3 Document Captured Requests

**Key things to capture:**
- API base URL
- Endpoints discovered
- Request parameters
- Response format (JSON/protobuf)
- Authentication headers
- Rate limiting behavior
- Error responses

**Example captured endpoint:**
```
GET https://api.tokopedia.com/v2/product?search=laptop

Headers:
- User-Agent: [captured]
- Authorization: [captured]
- X-Device-ID: [captured]

Response: JSON
{
  "data": {
    "products": [...]
  }
}
```

---

## 📊 Phase 6: Documentation & Analysis (Day 6)

### 6.1 Export Burp HTTP History

**From Burp Suite:**
```
1. Proxy → HTTP history
2. Select all requests (Ctrl+A)
3. Right-click → Save items
4. Format: CSV or JSON
5. Save as: tokopedia_api_traffic.csv
```

### 6.2 Create API Endpoints Documentation

**Template:**

```markdown
# Tokopedia Lite API Endpoints

## 1. Search Products
- **Endpoint:** GET /api/v2/product
- **Parameters:**
  - search: string (product name)
  - page: integer (pagination)
  - limit: integer (results per page)
- **Response:** JSON
- **Example:** GET /api/v2/product?search=laptop&page=1&limit=20

## 2. Get Product Details
- **Endpoint:** GET /api/v2/product/{id}
- **Parameters:**
  - id: string (product ID)
- **Response:** JSON with full product info
- **Authentication:** Required (Bearer token)

## 3. Get User Profile
- **Endpoint:** GET /api/v1/user/profile
- **Parameters:** None
- **Response:** JSON with user data
- **Authentication:** Required
- **Headers:**
  - Authorization: Bearer {token}
  - X-Device-ID: {device_id}

[Continue for all discovered endpoints...]
```

### 6.3 Identify Authentication Mechanism

**Look for:**
- Login endpoint & parameters
- Token generation method
- Token storage/refresh logic
- Session management
- Device fingerprinting (X-Device-ID, etc.)

**Example findings:**
```
Login Flow:
1. POST /api/v1/auth/login
   - phone: string
   - password: string
   
2. Returns: 
   - access_token (JWT?)
   - refresh_token
   - expires_in
   
3. Subsequent requests use:
   - Authorization: Bearer {access_token}
   - X-Device-ID: {device_id}
```

### 6.4 Security Observations

**Document any findings:**
- ✓ API uses HTTPS (verify cert pinning bypassed)
- ✓ Authentication mechanism
- ✓ Rate limiting (if any)
- ✓ Data encryption (if any)
- ✓ Sensitive data exposure (passwords, tokens)
- ✓ CORS/CSRF protection
- ✓ API versioning

---

## 📝 Phase 7: Report & Delivery (Day 7)

### 7.1 Deliverables Package

Prepare these files:

1. **tokopedia-lite-patched.apk**
   - Signed & ready to install
   - SSL Pinning bypass enabled

2. **tokopedia_api_traffic.csv/json**
   - Burp HTTP history export
   - All captured requests/responses

3. **API_ENDPOINTS_DOCUMENTATION.md**
   - All endpoints discovered
   - Parameters, methods, responses
   - Authentication requirements

4. **REVERSE_ENGINEERING_REPORT.md**
   - Executive summary
   - Methodology used
   - Key findings
   - Security observations
   - Screenshots/examples
   - Reproducibility steps

5. **SETUP_GUIDE.md**
   - How to setup environment
   - How to run patched APK
   - How to intercept traffic
   - How to analyze findings

### 7.2 Report Template

```markdown
# TOKOPEDIA LITE - REVERSE ENGINEERING REPORT

## Executive Summary
Brief overview of findings and key discoveries

## Methodology
1. Used APK Patcher to bypass SSL Pinning
2. Installed patched APK on Android device
3. Intercepted traffic using Burp Suite
4. Analyzed API communication patterns

## Key Findings

### 1. Authentication
- [Details about auth mechanism]

### 2. API Endpoints
- [List of discovered endpoints]

### 3. Data Format
- [Format and structure details]

### 4. Security Notes
- [Any security observations]

## Conclusions
Summary of findings and potential use cases

## Appendix
- Traffic logs
- Screenshots
- Full endpoint list
```

### 7.3 Package for Delivery

```powershell
# Create delivery folder
mkdir tokopedia-lite-report
cd tokopedia-lite-report

# Copy files
copy ..\tokopedia-lite-patched.apk .
copy ..\tokopedia_api_traffic.csv .
copy API_ENDPOINTS_DOCUMENTATION.md .
copy REVERSE_ENGINEERING_REPORT.md .
copy SETUP_GUIDE.md .

# Create zip
Compress-Archive -Path * -DestinationPath ..\tokopedia-lite-complete.zip
```

---

## ✅ Quality Checklist

Before delivery, verify:

- [ ] APK successfully patches without errors
- [ ] Patched APK installs on device/emulator
- [ ] App runs without crashing
- [ ] Burp intercepts traffic successfully
- [ ] All major API endpoints captured
- [ ] Authentication flow documented
- [ ] All requests/responses captured
- [ ] Documentation complete & accurate
- [ ] Report includes examples with screenshots
- [ ] Reproducibility steps clear
- [ ] No sensitive data leaked in documentation

---

## 🚨 Troubleshooting

### Issue: APK Patcher fails
```
Solution: Run setup_check.py to verify environment
```

### Issue: App crashes after patching
```
Solution: 
1. Check logcat: adb logcat | findstr tokopedia
2. Verify device architecture matches APK
3. Try different APK version
```

### Issue: Burp not intercepting traffic
```
Solution:
1. Verify device proxy settings
2. Check Burp listener is on 0.0.0.0:8080
3. Verify device CA certificate installed
4. Test with: curl http://example.com via device browser
```

### Issue: Device can't reach Burp
```
Solution:
1. Get computer IP: ipconfig
2. Verify both on same WiFi network
3. Check firewall allows port 8080
4. Try: adb connect 127.0.0.1:5555 (for emulator)
```

---

## 📞 Support & References

**Tools Documentation:**
- [APK Patcher README](README.md)
- [APK Patcher Quick Start](QUICKSTART.md)
- [Burp Suite Guide](https://portswigger.net/burp/documentation)
- [Charles Proxy Guide](https://www.charlesproxy.com/documentation/)

**Android References:**
- [Android Developer Docs](https://developer.android.com/)
- [Network Security Config](https://developer.android.com/training/articles/security-config)
- [Reverse Engineering Resources](https://github.com/t0data/android-re-resources)

---

## 📅 Timeline Estimate

| Phase | Days | Deliverable |
|-------|------|-------------|
| 1. Setup | 1 | Environment ready |
| 2. Patching | 1 | tokopedia-lite-patched.apk |
| 3. Device Setup | 1 | Device/emulator ready with Burp |
| 4. Installation | 0.5 | App installed & running |
| 5. Capture | 2 | All traffic captured |
| 6. Documentation | 1.5 | Full API documentation |
| 7. Report | 0.5 | Final report & delivery |
| **TOTAL** | **7** | **Complete package** |

---

## ✨ Success Criteria

Project is considered successful when:

1. ✓ Patched APK installed & running on device
2. ✓ Burp Suite capturing all app traffic
3. ✓ Minimum 50+ API endpoints documented
4. ✓ Authentication mechanism understood
5. ✓ Request/response structure clear
6. ✓ Complete documentation provided
7. ✓ Report includes examples & screenshots
8. ✓ All deliverables in single package

---

**Project Ready for Execution!** 🚀

All tools, scripts, and documentation prepared.
Waiting for APK to be obtained (manual download required due to licensing).

Once APK in place → Ready to execute.
