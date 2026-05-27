# 🎯 TRAFFIC CAPTURE - NEXT STEPS

## ✅ SETUP COMPLETE

```
Status: READY FOR TRAFFIC CAPTURE
├── Burp Community Edition ✅ Running on localhost:8080
├── Android Emulator ✅ Connected (emulator-5554)
├── Proxy Configuration ✅ 192.168.1.11:8080
├── Tokopedia App ✅ Installed & Launched
└── SSL Pinning ✅ Removed (APK patched)
```

---

## 📱 WHAT TO DO NOW

### Step 1: Open Burp Community Interface
Your Burp window should be visible. If not:
- Look for "Burp Suite Community Edition" in taskbar
- Alt+Tab to switch to Burp window

### Step 2: Navigate to Proxy → HTTP History
- Click on **Proxy** tab (top menu)
- Click on **HTTP History** subtab
- You should see a list of intercepted requests

### Step 3: Interact with Tokopedia App
In the emulator:
1. Scroll through products
2. Click on items
3. Search for products
4. Check shop details
5. View prices/ratings

**Each action = HTTP requests captured in Burp!**

---

## 🎯 WHAT TO LOOK FOR

### Primary Endpoints (GraphQL)
```
Endpoint: gql.tokopedia.com
Method: POST
Headers:
  - Content-Type: application/json
  - X-Device-Id: <device-id>
  - X-Source: app
```

**GraphQL Queries to Document:**
- `GetProductSearch` - Product search results
- `ProductDetail` - Detailed product info
- `ShopDetail` - Shop/seller information
- `GetShopRating` - Seller ratings

### Secondary Endpoints (REST)
```
ta.tokopedia.com/search/v2
ta.tokopedia.com/api/v1/product/<id>
ta.tokopedia.com/api/v1/shop/<id>
```

---

## 📝 CAPTURE INSTRUCTIONS

### For Each Request Found:
1. **Right-click on request** in HTTP History
2. **Copy to clipboard** or manually note:
   - Endpoint URL
   - HTTP Method (GET/POST)
   - Headers (especially auth-related)
   - Request body (if POST)
   - Response format (JSON/XML)

### Example to Document:
```json
{
  "endpoint": "https://gql.tokopedia.com",
  "method": "POST",
  "headers": {
    "Content-Type": "application/json",
    "X-Device-Id": "abc123def456",
    "User-Agent": "Tokopedia Android"
  },
  "query": "GetProductSearch",
  "variables": {
    "keyword": "laptop",
    "page": 1
  }
}
```

---

## ⚠️ TROUBLESHOOTING

### If No Traffic Appears:
1. **Check app is running:**
   ```bash
   adb shell ps | grep tokopedia
   ```

2. **Verify proxy configuration:**
   ```bash
   adb shell settings get global http_proxy
   # Should show: 192.168.1.11:8080
   ```

3. **Check Burp is listening:**
   ```bash
   Test-NetConnection -ComputerName localhost -Port 8080
   # Should show: TcpTestSucceeded = True
   ```

4. **Restart everything:**
   - Kill app: `adb shell am force-stop com.tokopedia.tokopro`
   - Kill Burp: Stop BurpSuite process
   - Restart Burp Community
   - Relaunch app

### If Certificate Error:
- Expected: The app is patched, should not need certificate
- If blocked: Check APK patching status
- Fallback: Extract Burp CA cert and install manually

---

## 💾 FILES READY FOR NEXT PHASE

Once you capture endpoints, these files are ready:
- `tokopedia_scraper.js` - Framework to integrate captured endpoints
- `TESTING_PLAN.md` - Full testing guide
- `QUICK_REFERENCE.md` - Command cheat sheet

---

## 🚀 QUICK ACTIONS

### Open Burp (if hidden):
```powershell
$adb = "C:\Users\rriat\AppData\Local\Android\sdk\platform-tools\adb.exe"

# Take screenshot of app
& $adb shell screencap -p /sdcard/screenshot.png
& $adb pull /sdcard/screenshot.png C:\Users\rriat\Downloads\

# Check running processes
& $adb shell ps | findstr tokopedia

# Kill and restart app
& $adb shell am force-stop com.tokopedia.tokopro
Start-Sleep 2
& $adb shell am start -n "com.tokopedia.tokopro/com.ss.android.ugc.aweme.splash.SplashActivity"
```

### Monitor app logs:
```bash
adb logcat | findstr "tokopedia"
```

---

## 📊 SUCCESS INDICATORS

✅ You'll know it's working when:
1. Burp HTTP History shows **tokopedia.com** requests
2. Requests show **JSON** response bodies
3. You can see **authentication headers**
4. Clicking app items = new requests appear

---

## NEXT STEPS AFTER CAPTURE

1. **Document 5-10 key endpoints** from traffic
2. **Export request/response examples** from Burp
3. **Integrate into `tokopedia_scraper.js`** with real URLs
4. **Test scraper against live API**
5. **Deploy to cloud** (DigitalOcean) for 24/7 operation

---

**Questions?** Review BURP_COMMUNITY_SETUP.md or QUICK_REFERENCE.md
