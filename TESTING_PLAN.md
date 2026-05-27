# 🧪 TOKOPEDIA BURP TESTING - EXECUTION PLAN

**Project Status:** Ready for Traffic Capture & API Analysis  
**Date:** May 26, 2026  
**Next Phase:** Burp Suite Setup + Traffic Interception Testing

---

## ✅ Current Status

### What's Ready
```
✓ Emulator: emulator-5554 (running)
✓ Tokopedia App: com.tokopedia.tokopro (installed)
✓ APK Patching: SSL pinning removed ✅
✓ Documentation: Updated for Burp Suite ✅
✓ Setup Scripts: Charles files deleted, burp_setup_final.ps1 created ✅
```

### What's Needed
```
⏳ Download Burp Suite Community Edition
⏳ Install Burp
⏳ Run setup automation script
⏳ Start traffic capture
```

---

## 📋 STEP-BY-STEP TESTING PLAN

### PHASE 1: DOWNLOAD & INSTALL BURP (5 minutes)

**Option A: Auto Download (Recommended)**
```powershell
cd "C:\Users\rriat\OneDrive\Dokumen\test\testing"

# Run installer script
.\install_burp.ps1
```

**Option B: Manual Download**
1. Go to: https://portswigger.net/burp/communitydownload
2. Click: "Download Community Edition"
3. Download `BurpSuiteCommunity-Windows-*.exe`
4. Double-click to install (default location OK)
5. Wait for installation to complete

---

### PHASE 2: RUN BURP SETUP AUTOMATION (15 minutes)

**Prerequisites:**
- Burp Suite must be installed
- Android emulator must be running
- Tokopedia app must be installed

**Execute:**
```powershell
cd "C:\Users\rriat\OneDrive\Dokumen\test\testing"

# Run complete automation
.\burp_setup_final.ps1
```

**What This Script Does:**
1. ✓ Verifies Burp installation
2. ✓ Checks emulator/device connection
3. ✓ Starts Burp Suite
4. ✓ Extracts CA certificate
5. ✓ Configures emulator proxy (192.168.1.X:8080)
6. ✓ Installs certificate to emulator
7. ✓ Starts listening for traffic

**Manual Steps (if auto-cert extraction fails):**
```
In Burp Suite:
  1. Proxy → Options → CA Certificate
  2. Click "Save..." 
  3. Select "Certificate in DER format"
  4. Save as: burp-cacert.der
  5. Location: C:\Users\rriat\OneDrive\Dokumen\test\testing\
  
Then the script will convert DER → PEM automatically.
```

---

### PHASE 3: VERIFY PROXY CONFIGURATION (5 minutes)

**Check Emulator Proxy:**
```powershell
# Verify proxy is set
$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"
& $adbPath shell settings get global http_proxy
& $adbPath shell settings get global https_proxy

# Expected output: 192.168.1.X:8080
```

**Test Network Connection:**
```powershell
# Verify emulator can reach Burp
& $adbPath shell ping -c 1 8.8.8.8

# Check if traffic will route through proxy
& $adbPath shell curl -I https://tokopedia.com
```

---

### PHASE 4: START BURP TRAFFIC CAPTURE (Ongoing)

**In Burp Suite (Already Running):**
1. Go to: **Proxy → HTTP History**
2. Verify no traffic yet (empty)
3. Watch for incoming requests

**On Emulator (Tokopedia App):**
1. Open Tokopedia app
2. Navigate through:
   - Homepage
   - Search for a product
   - View product details
   - Check reviews
   - View merchant page
   - Check any other feature

**In Burp:**
- All traffic will appear in **HTTP History tab**
- Each request shows:
  - URL
  - Request method (GET/POST)
  - Response status (200, 401, 429, etc)
  - Request/response headers
  - Body (JSON, protobuf, etc)

---

### PHASE 5: ANALYZE CAPTURED API CALLS (1-2 hours)

**Key Endpoints to Look For:**

| Endpoint | Method | Purpose | Look For |
|----------|--------|---------|----------|
| gql.tokopedia.com/graphql | POST | Main API | GraphQL queries, auth headers |
| ta.tokopedia.com/search/v2* | GET | Search | Query params, pagination |
| ta.tokopedia.com/api/v1/product/* | GET | Product detail | Product ID param |
| ta.tokopedia.com/api/v1/shop/* | GET | Shop info | Shop ID param |

**In Burp - Click Any Request to See:**
```
REQUEST:
  - URL: Full endpoint
  - Method: GET/POST/etc
  - Headers: Device-ID, Session-ID, User-Agent
  - Body: JSON/protobuf payload

RESPONSE:
  - Status: 200 OK, 401 Unauthorized, etc
  - Headers: Content-type, cache-control
  - Body: Response data (product info, search results, etc)
```

**Save for Later Analysis:**
```
In Burp:
  1. Select all requests
  2. Right-click → "Copy to clipboard"
  3. Paste into text file for documentation
  
  OR:
  
  1. File → Generate Report
  2. Select format (HTML, XML, CSV)
  3. Save to: C:\Users\rriat\OneDrive\Dokumen\test\testing\
```

---

### PHASE 6: TROUBLESHOOTING (If Needed)

**Problem: No traffic appearing in Burp**
```
Solutions:
1. Check emulator proxy setting:
   Settings → Wi-Fi → Edit "Emulator" → Proxy
   Should show: 192.168.1.X:8080
   
2. Check certificate installed:
   Settings → Security → View CA Certificates
   Should see: "Burp CA" in "User" certificates
   
3. Check Burp is running:
   - Look for Burp window
   - If minimized, restore it
   - Proxy → Intercept → Check enabled/disabled
```

**Problem: Certificate not trusted (RED icon in Burp)**
```
Solutions:
1. Reinstall certificate:
   - Settings → Security → Install from storage
   - Select burp-cacert.pem from /sdcard/
   
2. Clear app cache & restart:
   adb shell pm clear com.tokopedia.tokopro
   adb shell am start -n com.tokopedia.tokopro/.MainActivity
```

**Problem: IP is blocked (403 Forbidden)**
```
Solutions:
1. Use VPN/Proxy:
   - Check if Tokopedia blocks local IPs
   - May need to use cloud VM (DigitalOcean, AWS)
   
2. Rotate Device-ID:
   - Modify User-Agent in Burp Repeater
   - Try different Device IDs
```

---

## 📊 SUCCESS CRITERIA

### ✅ Phase 1-2 Complete When:
```
[✓] Burp Suite starts without errors
[✓] Emulator detects proxy setting
[✓] Certificate shows in emulator Security → CA Certificates
```

### ✅ Phase 3-4 Complete When:
```
[✓] At least 5+ API requests appear in Burp HTTP History
[✓] Requests show actual Tokopedia endpoints (gql.tokopedia.com, ta.tokopedia.com)
[✓] Response status 200 OK (not 403 or 401)
[✓] Response body contains real data (JSON with merchant/product info)
```

### ✅ Phase 5 Complete When:
```
[✓] Documented at least 10 API endpoints
[✓] Identified auth headers (Device-ID, Session-ID)
[✓] Extracted request/response examples
[✓] Saved sample traffic for implementation phase
```

---

## 🚀 NEXT STEPS AFTER SUCCESSFUL CAPTURE

Once you have captured traffic successfully:

### 1. Document API Endpoints
```
Create: api_endpoints_captured.txt

Format:
---
ENDPOINT: https://gql.tokopedia.com/graphql
METHOD: POST
AUTH HEADERS: Device-ID, Session-ID, User-Agent
REQUEST BODY: [GraphQL query example]
RESPONSE: [JSON response example]
RATE LIMIT: [Observed limits]
---
```

### 2. Update Scraper Framework
```
File: tokopedia_scraper.js

Update with:
- Real endpoints (from captured traffic)
- Actual auth headers
- Request format (JSON vs protobuf)
- Error handling for rate limits
```

### 3. Test & Deploy
```
Test locally:
  node tokopedia_scraper.js --test

Deploy to cloud:
  - Copy to DigitalOcean droplet
  - Setup Node.js + dependencies
  - Configure .env with real endpoints
  - Start auto-scraping
```

---

## 📝 TESTING CHECKLIST

- [ ] **INSTALL**
  - [ ] Burp Suite installed & running
  - [ ] Emulator connected (adb devices shows emulator-5554)
  - [ ] Tokopedia app installed (adb shell pm list packages | grep tokopedia)

- [ ] **CONFIGURE**
  - [ ] Proxy configured on emulator (adb shell settings get global http_proxy)
  - [ ] Certificate installed on emulator (Settings → Security → CA Certificates)
  - [ ] Burp listening on port 8080

- [ ] **CAPTURE**
  - [ ] Burp HTTP History shows traffic (not empty)
  - [ ] At least 5 requests captured from app
  - [ ] Requests show tokopedia.com domains
  - [ ] Response status 200 OK (success)

- [ ] **ANALYZE**
  - [ ] Identified GraphQL endpoint
  - [ ] Identified REST endpoints (search, product, shop)
  - [ ] Extracted auth headers
  - [ ] Saved sample request/response

- [ ] **DOCUMENT**
  - [ ] Endpoints documented
  - [ ] Headers documented
  - [ ] Rate limits noted
  - [ ] Data models identified

---

## 📞 SUPPORT

If stuck:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
2. Review [TOKOPEDIA_FINAL_SETUP.md](TOKOPEDIA_FINAL_SETUP.md) for detailed steps
3. Check Burp documentation: https://portswigger.net/burp/documentation

---

**Ready to test?** Start with PHASE 1: Download Burp Suite! 🚀
