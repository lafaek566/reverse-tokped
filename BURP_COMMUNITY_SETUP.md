# BURP COMMUNITY SETUP CHECKLIST ✅

## Installation Status
- [ ] Installer wizard completed
- [ ] Burp Community installed to C:\Program Files\BurpSuiteCommunity
- [ ] Ready to launch

## Quick Setup After Installation (Next Steps)
```
1. Launch Burp Community
2. Accept the startup wizard (no DAST required - big advantage!)
3. Go to Proxy → Options
4. Verify listening on 127.0.0.1:8080
5. Download CA Certificate (Proxy → Options → Import/Export CA certificate)
6. Install on Android emulator
7. Configure emulator proxy: adb shell settings put global http_proxy 192.168.1.11:8080
8. Start capturing traffic!
```

## Important Differences: Community vs Enterprise
| Feature | Community | Enterprise |
|---------|-----------|-----------|
| Proxy capture | ✅ YES | ✅ YES |
| Setup wizard | ⚡ SIMPLE (no DAST) | 🔴 Complex (requires DB) |
| Ports | 8080, 8443 | 8080, 8443 |
| Price | 🎉 FREE | 💰 Expensive |
| What we need | ✅ ALL | ✅ Only proxy |

## Emulator Configuration (Ready to Use)
```bash
# Already configured:
adb shell settings put global http_proxy 192.168.1.11:8080

# Can verify with:
adb shell settings get global http_proxy
# Should show: 192.168.1.11:8080
```

## Tokopedia Traffic Capture
**Target Endpoints:**
- `gql.tokopedia.com` - GraphQL queries
- `ta.tokopedia.com` - REST API
- `voucherlist.tokopedia.com` - Vouchers
- `www-gw.tokopedia.com` - App gateway

**Look for in Burp HTTP History:**
- All requests should show in Proxy tab
- Filter: `tokopedia` to see target traffic
- Check request/response headers for auth tokens
- Document endpoint URLs and parameters

## Next Actions (Wait for Installation)
1. ✅ Report: "Installer done!"
2. Launch Burp Community
3. Accept startup wizard
4. Extract CA certificate
5. Install on emulator
6. Launch Tokopedia app
7. Watch traffic in Burp!
