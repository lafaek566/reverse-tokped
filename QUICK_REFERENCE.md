# ⚡ QUICK REFERENCE - BURP TESTING COMMANDS

## 📋 One-Liner Setup

```powershell
# Step 1: Download & Install Burp
cd C:\Users\rriat\OneDrive\Dokumen\test\testing
.\install_burp.ps1

# Step 2: Run Complete Setup (requires Burp installed)
.\burp_setup_final.ps1

# Step 3: Open Testing Guide
code TESTING_PLAN.md
```

---

## 🔧 ADB COMMANDS (Manual Testing)

```powershell
# Set ADB path (if not in PATH)
$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Check devices
& $adbPath devices

# Configure proxy manually
& $adbPath shell settings put global http_proxy "192.168.1.11:8080"
& $adbPath shell settings put global https_proxy "192.168.1.11:8080"

# Disable proxy (after testing)
& $adbPath shell settings put global http_proxy :0
& $adbPath shell settings put global https_proxy :0

# Check current proxy
& $adbPath shell settings get global http_proxy

# Install certificate
& $adbPath push burp-cacert.pem /sdcard/

# Clear Tokopedia cache
& $adbPath shell pm clear com.tokopedia.tokopro

# Restart Tokopedia app
& $adbPath shell am start -n com.tokopedia.tokopro/.MainActivity

# View app logs (live)
& $adbPath logcat | Select-String -Pattern "tokopedia|tokopro"

# Stop logcat
# Ctrl+C
```

---

## 🎯 BURP CONSOLE SHORTCUTS

| Task | Path |
|------|------|
| View traffic | Proxy → HTTP History |
| Intercept requests | Proxy → Intercept → Is intercept on/off? |
| Decode/encode | Decoder tab |
| Test manually | Repeater tab |
| Analyze responses | HTTP History → Click request |
| Save traffic | File → Export → All items |
| Search traffic | Proxy → HTTP History → Search box (Ctrl+F) |

---

## 🧪 TESTING WORKFLOW

### 1. Start Capture
```
1. Burp running → Proxy tab open
2. Emulator proxy configured
3. Certificate installed
4. Tokopedia app open
→ Watch Proxy → HTTP History for traffic
```

### 2. Generate Traffic
```
On emulator:
- Navigate home
- Search for product
- View product details
- Click shop page
- Check reviews
- Like products
→ Each action generates API calls
```

### 3. Analyze Response
```
In Burp HTTP History:
1. Click on request
2. View: Request → Headers → Body
3. View: Response → Headers → Body
4. Note: URL, method, status code, headers
```

### 4. Save for Later
```
Option A (Clipboard):
  Right-click request → Copy to clipboard
  
Option B (File):
  File → Export → Export all items
  Choose format: JSON/CSV/HTML
  Save location
  
Option C (Screenshot):
  Print Screen while viewing in Burp
```

---

## 🆘 TROUBLESHOOTING QUICK FIXES

### No traffic in Burp?
```powershell
# Check emulator proxy is SET
& $adbPath shell settings get global http_proxy
# Should return: 192.168.1.X:8080

# Check certificate is installed
& $adbPath shell am start -a android.settings.SETTINGS
# Settings → Security → CA Certificates → Look for "Burp CA"

# Restart app
& $adbPath shell am force-stop com.tokopedia.tokopro
& $adbPath shell am start -n com.tokopedia.tokopro/.MainActivity
```

### Certificate not trusted (RED icon)?
```powershell
# Reinstall from device Settings:
Settings → Security → Install from storage
Select: burp-cacert.pem
Name: Burp CA
Used for: VPN and apps

# Or reinstall via ADB:
& $adbPath push burp-cacert.pem /sdcard/Download/
# Then Settings → Security → Install from storage
```

### Getting 403/IP Blocked?
```powershell
# This means local IP is blocked by Tokopedia anti-bot
# Solutions:
# 1. Use VPN on Windows (before proxy)
# 2. Use cloud VM (DigitalOcean - $8/month)
# 3. Rotate Device-ID in requests

# Test IP reputation:
# https://whatismyipaddress.com/
# https://www.abuseipdb.com/
```

### Proxy connections failing?
```powershell
# Test network from emulator
& $adbPath shell ping -c 1 8.8.8.8
& $adbPath shell curl -I https://tokopedia.com

# If fails, network issue
# If works but traffic not in Burp, certificate issue
```

---

## 📊 EXPECTED TRAFFIC PATTERNS

### Success Indicators
```
✓ GET/POST requests to gql.tokopedia.com
✓ GET requests to ta.tokopedia.com/search/v2*
✓ GET requests to ta.tokopedia.com/api/v1/product/*
✓ Response status 200 (not 403/401)
✓ Response body has JSON/text (real data)
✓ Headers include Device-ID, Session-ID
```

### Common Endpoints (Look For These)
```
https://gql.tokopedia.com/graphql                    → GraphQL API
https://ta.tokopedia.com/search/v2.8/                → Product Search
https://ta.tokopedia.com/api/v1/product/{id}         → Product Detail
https://ta.tokopedia.com/api/v1/shop/{id}            → Shop Info
https://ta.tokopedia.com/api/v1/review/list/{id}     → Reviews
```

---

## 📱 KEY FILES

| File | Purpose |
|------|---------|
| [burp_setup_final.ps1](burp_setup_final.ps1) | Complete automation script |
| [START_TESTING.ps1](START_TESTING.ps1) | Quick launcher menu |
| [TESTING_PLAN.md](TESTING_PLAN.md) | Detailed step-by-step guide |
| [TOKOPEDIA_FINAL_SETUP.md](TOKOPEDIA_FINAL_SETUP.md) | Original setup guide (Burp version) |
| [install_burp.ps1](install_burp.ps1) | Burp downloader script |

---

## ✅ TESTING CHECKLIST

Before starting:
- [ ] Emulator running (adb devices shows emulator-5554)
- [ ] Tokopedia installed (adb shell pm list packages | grep tokopedia)
- [ ] Burp downloaded & installed
- [ ] Windows IP detected correctly
- [ ] Network connectivity OK

During capture:
- [ ] Traffic appearing in Burp
- [ ] Requests from tokopedia.com domains
- [ ] Response status 200 (success)
- [ ] Response contains real data
- [ ] At least 10 requests captured

After capture:
- [ ] Endpoints documented
- [ ] Headers noted
- [ ] Rate limits observed
- [ ] Auth tokens identified
- [ ] Data saved for implementation

---

## 🚀 NEXT PHASE

Once traffic captured successfully:
```
1. Document endpoints → api_endpoints_captured.txt
2. Update scraper → tokopedia_scraper.js
3. Test locally → node tokopedia_scraper.js --test
4. Deploy to cloud → DigitalOcean droplet
5. Monitor scraping → 24/7 auto-updates
```

---

**Ready? Run:** `.\START_TESTING.ps1`
