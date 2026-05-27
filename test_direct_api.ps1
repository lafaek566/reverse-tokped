#!/usr/bin/env powershell
# DIRECT API TEST - BYPASS CHARLES CERTIFICATE ISSUE

Write-Host "Testing Direct API Calls via Tokopedia Scraper`n" -ForegroundColor Cyan
Write-Host "This will capture API responses without Charles certificate`n" -ForegroundColor Yellow

$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"

# Push Node.js script to device to test API
Write-Host "[1] Testing GraphQL endpoint directly..." -ForegroundColor Yellow

$testScript = @'
const https = require("https");

const query = `{
  feedV2(
    limit: 5
    order: "BestSelling"
  ) {
    items {
      id
      title
      originalPrice
      discountPrice
    }
  }
}`;

const options = {
  hostname: "gql.tokopedia.com",
  port: 443,
  path: "/graphql",
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "User-Agent": "Tokopedia/Android",
    "Device-Id": Math.random().toString(36).substring(7)
  }
};

const req = https.request(options, (res) => {
  let data = "";
  res.on("data", chunk => data += chunk);
  res.on("end", () => {
    console.log("Status:", res.statusCode);
    console.log("Response:", data.substring(0, 500));
  });
});

req.on("error", (e) => console.error("Error:", e.message));
req.write(JSON.stringify({ query }));
req.end();
'@

Write-Host $testScript

Write-Host "`n[2] Checking if Node.js is available on emulator..." -ForegroundColor Yellow

$nodeCheck = & $adbPath shell "which node" 2>&1

if ($nodeCheck -match "not found") {
    Write-Host "Node.js not on emulator (expected)" -ForegroundColor Yellow
    Write-Host "Will test via desktop instead..." -ForegroundColor Gray
} else {
    Write-Host "Node.js found: $nodeCheck" -ForegroundColor Green
}

# Alternative: Test via curl on emulator with cleartext
Write-Host "`n[3] Testing with curl (checking connectivity)..." -ForegroundColor Yellow

$curlTest = & $adbPath shell "curl -s -H 'User-Agent: Tokopedia/Android' https://ta.tokopedia.com/api/v1/help/search?q=test 2>&1" | Select-String -Pattern "error|Could not|refused"

if ($curlTest) {
    Write-Host "Curl result: $curlTest" -ForegroundColor Red
} else {
    Write-Host "Curl request sent" -ForegroundColor Green
}

# Check if app made network activity
Write-Host "`n[4] Checking app network connections..." -ForegroundColor Yellow

$netstat = & $adbPath shell "netstat | grep -i tokopedia" 2>&1

if ($netstat) {
    Write-Host "Found Tokopedia connections:" -ForegroundColor Green
    Write-Host $netstat
} else {
    Write-Host "No active Tokopedia connections" -ForegroundColor Yellow
}

Write-Host "`n[MANUAL NEXT STEPS]" -ForegroundColor Cyan
Write-Host @"
Since certificate issue blocking Charles decryption:

Option 1: Use Burp Suite instead
- Burp has better Android integration
- Can intercept without complex cert setup

Option 2: Export encrypted traffic from Charles
- Charles > File > Export Sessions
- Save all captured requests (even encrypted)
- Analyze patterns

Option 3: Use Frida for dynamic analysis
- Inject into app process
- Bypass SSL pinning programmatically
- Capture credentials in memory

For now:
1. Check Charles for ANY captured traffic (even encrypted)
2. Look for domains: gql.tokopedia.com, ta.tokopedia.com
3. Screenshot and share
"@ -ForegroundColor Yellow
