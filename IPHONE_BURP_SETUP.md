# 📱 iPhone + Burp Suite Setup Guide

## Overview
Capture Tokopedia app traffic dari iPhone menggunakan Burp Suite Community Edition sebagai proxy.

---

## Prerequisites
- ✅ Burp Suite running di komputer (port 8080)
- ✅ iPhone di WiFi yang sama dengan komputer
- ✅ Tokopedia app installed di iPhone

---

## Step 1: Get Computer IP Address

### Windows:
```powershell
ipconfig
```

Cari yang mirip: `192.168.1.10` atau `10.0.0.x`

### Mac:
```bash
ifconfig | grep inet
```

**Catat IP ini!** (misal: `192.168.1.10`)

---

## Step 2: Verify Burp Running

1. Open browser: `http://localhost:8080`
2. Should show Burp Suite dashboard ✅
3. Note down port: **8080**

---

## Step 3: Configure iPhone WiFi Proxy

### On iPhone:
1. **Settings** → **WiFi**
2. Tap connected network → **Modify Settings** (or "i" icon)
3. Scroll down to **HTTP PROXY**
4. Select **Configure Proxy** → **Manual**
5. Enter:
   - **Server:** `192.168.1.10` (your PC IP)
   - **Port:** `8080`
6. Tap **Save**

### Verify:
- Check WiFi name shows a "⚙️" icon (proxy active)

---

## Step 4: Install Burp CA Certificate

### Option A: Automatic (Recommended)

1. On iPhone, open Safari
2. Navigate to: `http://burp` (if on same network)
3. Or: `http://192.168.1.10:8080/cert` 
4. Tap "CA Certificate" download
5. Notification: "Profile Downloaded"
6. Go to **Settings** → **General** → **VPN & Device Management**
7. Select "Burp Root Certificate"
8. Tap **Install** → Enter Passcode

### Option B: Manual Certificate Trust

After installation:
1. **Settings** → **General** → **About**
2. Scroll down to **Certificate Trust Settings**
3. Find "Burp Proxy CA"
4. Enable the toggle ✓

---

## Step 5: Test Connection

### Test 1: Safari Traffic
1. On iPhone, open Safari
2. Visit: `https://www.example.com`
3. Check Burp Proxy tab → **HTTP History**
4. Should see the request! ✅

### Test 2: Tokopedia App
1. Close Tokopedia app completely
2. Reopen Tokopedia app
3. Navigate around the app
4. Check Burp for traffic

---

## Troubleshooting

### Issue: No traffic appears in Burp

**Solution 1: Check Proxy Settings**
```
Settings → WiFi → Connected Network
Verify Server IP and Port 8080 correct
```

**Solution 2: Restart Burp**
```
Close Burp completely
Restart Burp Suite
Try again
```

**Solution 3: Certificate Not Trusted**
```
Check: Settings → General → About → Certificate Trust Settings
Enable Burp certificate toggle
```

**Solution 4: Firewall Blocking**
```
Windows Firewall may block port 8080
Add Burp to Windows Firewall exceptions:
  Settings → Firewall & Network Protection → Allow an app through firewall
  Enable "Burp Suite"
```

---

## Common Issues

### "Cannot Connect to Proxy"
- iPhone can't reach computer IP
- **Fix:** Test: `ping 192.168.1.10` from computer
- Check both devices on SAME WiFi
- Not using guest WiFi (may be isolated)

### "Certificate Not Valid"
- Certificate installation incomplete
- **Fix:** Go to Settings → VPN & Device Management → Install again
- Check Settings → About → Certificate Trust Settings

### Tokopedia Still Shows No Errors But No Traffic
- App may have **SSL Pinning** enabled
- Even with proxy, encrypted traffic can't be decrypted
- **This is expected** - apps implement this for security

### App Says "No Internet" 
- Proxy not correctly forwarding
- **Fix:** Check Burp settings: Proxy → Options → Binding
- Should listen on 0.0.0.0:8080 (all interfaces)

---

## What Traffic You'll See

### ✅ Capturable
- Safari requests
- HTTP (unencrypted) traffic
- APIs from apps without SSL pinning
- WebSocket traffic

### ❌ May Not See (SSL Pinning)
- Tokopedia app (if has pinning)
- Banking apps
- Other security-hardened apps

---

## Next Steps

1. If Tokopedia traffic visible:
   - Analyze requests in Burp
   - Find API endpoints
   - Document authentication headers
   - Save requests for later analysis

2. If Tokopedia not visible:
   - Consider using direct API scraper (already built in repo)
   - App-level security prevents proxy capture
   - Direct API approach is more reliable

---

## Direct API Alternative

If Tokopedia has SSL pinning and you can't capture traffic:
- Already have working **direct API scraper** in repository
- Uses actual Tokopedia API endpoints
- No need for traffic capture
- Ready to deploy to production

See: `DEPLOY_TO_RAILWAY.md`

---

## References

- Burp Suite Community: https://portswigger.net/burp
- iPhone Proxy Setup: https://support.apple.com/en-us/HT202330
- Burp Certificates: https://portswigger.net/support/installing-burp-suites-ca-certificate-in-an-ios-device

---

**Questions?** Check troubleshooting section above or check Burp Suite docs.
