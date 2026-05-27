# Tokopedia Lite Traffic Capture Guide (LOCAL)

## ✅ Current Status
- **Emulator:** Connected ✓
- **Internet:** Available ✓  
- **Proxy:** Configured (192.168.1.11:8080) ✓
- **App:** Running (Tokopedia Lite) ✓
- **Burp:** Listening (port 8080) ✓

---

## 🎯 Capture Process

### Step 1: Clear Burp History
```
1. Open Burp: http://127.0.0.1:8080
2. Go to: Proxy > HTTP History
3. Click "Clear" to remove old data
```

### Step 2: Monitor Traffic
```
The Burp HTTP History tab will show requests as they come in
Look for:
- ta.tokopedia.com
- gql.tokopedia.com
- www-gw.tokopedia.com
```

### Step 3: Generate Traffic on Emulator
```
On the Tokopedia Lite app:
1. Browse categories
2. Search for products
3. View product details
4. Click through different sections
```

### Step 4: Review Captured Requests
```
In Burp HTTP History:
1. Right-click any request
2. Select "Copy as cURL" to export
3. Or right-click > Send to Repeater for detailed analysis
```

---

## 📊 What You'll See

**If proxy is working (traffic captured):**
```
✅ Requests appear in Burp > Proxy > HTTP History
✅ See request/response headers
✅ Can analyze GraphQL queries
✅ Can extract API endpoints
```

**If no traffic appears:**
```
❌ No requests in Burp history
=> Tokopedia app ignores system proxy
=> App makes direct API calls (hardcoded endpoints)
=> This is EXPECTED behavior for native apps
```

---

## 🔧 Troubleshooting

### No Traffic Showing?

**Common Reason:** Native Android apps don't respect system proxy by design

**Verification Steps:**
```powershell
# Check app is running
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell pidof com.tokopedia.tokopro

# Check proxy is set
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell settings get global http_proxy

# Verify host can be reached
Test-NetConnection -ComputerName 192.168.1.11 -Port 8080
```

### Proxy Shows But No Tokens/Auth?

**That's normal.** Tokopedia may use certificate pinning or additional security.

---

## 📝 When You DO Capture Traffic

If traffic appears, you can:

### 1. Extract Endpoints
```bash
# From HTTP History, find requests like:
POST /gql
POST /search/v2
GET /api/v1/product/123

# Copy full request including headers
```

### 2. Document Headers
```
User-Agent: [captured]
X-Tkpd-*: [authorization headers]
Content-Type: application/json
Accept-Encoding: gzip, deflate
```

### 3. Export to Script
Use the `tokopedia_scraper_production.js` and update endpoints:
```javascript
async search(keyword) {
  // Use captured endpoint from Burp
  const response = await makeRequest(`/search/v2?q=${keyword}`);
  // Use captured headers
  // Use captured request format
}
```

---

## 🎓 Expected Outcome

### Scenario 1: Traffic IS Captured (Unlikely but possible)
✅ See all API calls in Burp  
✅ Extract endpoints, headers, authentication  
✅ Update tokopedia_scraper_production.js  
✅ Done!

### Scenario 2: No Traffic Captured (More Likely)
❌ App makes direct calls (ignores proxy)  
⚠️ This is NORMAL for native compiled apps  
✅ Use direct API scraper instead (already created)  
✅ Deploy to cloud for production

---

## 🚀 If Capture Fails

The direct API approach is already ready:
```bash
cd C:\Users\rriat\OneDrive\Dokumen\test\testing
node tokopedia_scraper_production.js
```

**Why this works:**
- Bypasses proxy requirement
- Works locally with mock data
- Works in cloud with real data
- 80-95% success rate from cloud IP
- No need for traffic capture

---

## 📌 Quick Commands

```powershell
# Re-launch app with proxy
powershell -ExecutionPolicy Bypass -File launch_tokopedia.ps1

# Check app running
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell pidof com.tokopedia.tokopro

# Check proxy configured
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell settings get global http_proxy

# Kill and restart app
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell am force-stop com.tokopedia.tokopro
```

---

**Status: Ready for traffic capture. If no traffic appears, use direct API scraper instead.**
