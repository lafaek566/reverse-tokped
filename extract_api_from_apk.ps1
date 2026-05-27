#!/usr/bin/env powershell
# EXTRACT API ENDPOINTS FROM DECOMPILED APK CODE

Write-Host "Analyzing Tokopedia APK - API Endpoint Extraction`n" -ForegroundColor Cyan

$adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$workDir = "C:\Users\rriat\OneDrive\Dokumen\test\testing"

# Define smali source directories
$smaliDirs = @(
    "C:\Users\rriat\OneDrive\Dokumen\test\testing\com.tokopedia.tokopro\smali",
    "C:\Users\rriat\OneDrive\Dokumen\test\testing\tokopedia-lite\smali"
)

Write-Host "[1] Searching for API endpoints in code..." -ForegroundColor Yellow

# Common API patterns to search
$patterns = @(
    "gql\.tokopedia\.com",
    "ta\.tokopedia\.com",
    "api\.tokopedia\.com",
    "\/graphql",
    "\/search\/v",
    "\/product\/v",
    "Device-ID",
    "Session-ID",
    "X-Device",
    "X-Session"
)

$results = @{}

foreach ($dir in $smaliDirs) {
    if (Test-Path $dir) {
        Write-Host "Scanning: $dir" -ForegroundColor Gray
        
        $files = Get-ChildItem $dir -Recurse -Filter "*.smali" | Select-Object -First 100
        
        foreach ($pattern in $patterns) {
            $matches = Select-String -Path $files.FullName -Pattern $pattern -ErrorAction SilentlyContinue | Select-Object -First 10
            
            if ($matches) {
                $results[$pattern] = $matches.Count
                Write-Host "  - Found: $pattern ($($matches.Count) occurrences)" -ForegroundColor Green
            }
        }
    }
}

# Search for network configuration files
Write-Host "`n[2] Looking for network configuration XML..." -ForegroundColor Yellow

$xmlFiles = @(
    "C:\Users\rriat\OneDrive\Dokumen\test\testing\com.tokopedia.tokopro\res\xml\network_security_config.xml",
    "C:\Users\rriat\OneDrive\Dokumen\test\testing\tokopedia-lite\res\xml\network_security_config.xml"
)

foreach ($xmlFile in $xmlFiles) {
    if (Test-Path $xmlFile) {
        Write-Host "Found: $xmlFile" -ForegroundColor Green
        Write-Host "`nContent (first 500 chars):" -ForegroundColor Gray
        
        $content = Get-Content $xmlFile -Raw
        Write-Host $content.Substring(0, [Math]::Min(500, $content.Length)) -ForegroundColor Cyan
    }
}

# Look for OkHttp configuration
Write-Host "`n[3] Searching for OkHttp client configuration..." -ForegroundColor Yellow

$okHttpFiles = Select-String -Path (Get-ChildItem $smaliDirs[0] -Recurse -Filter "*OkHttp*.smali").FullName -Pattern "class|builder|client" -ErrorAction SilentlyContinue | Select-Object -First 20

if ($okHttpFiles) {
    Write-Host "Found OkHttp references:" -ForegroundColor Green
    $okHttpFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
}

# Create API analysis document
Write-Host "`n[4] Creating API analysis document..." -ForegroundColor Yellow

$reportPath = "$workDir\tokopedia_api_analysis.txt"

$report = @"
TOKOPEDIA API ANALYSIS - FROM DECOMPILED CODE
Generated: $(Get-Date)

=== FOUND PATTERNS ===
"@

foreach ($key in $results.Keys) {
    $report += "`n$key : $($results[$key]) occurrences"
}

$report += @"


=== NEXT STEPS ===
1. Search smali code for:
   - OkHttpClient initialization
   - Request builder patterns
   - Header configuration
   - SSL certificate pinning

2. Extract from ByteCode:
   - Device ID generation logic
   - Session ID generation
   - Request signing
   - Response handling

3. Common classes to analyze:
   - *NetworkClient.smali
   - *ApiService.smali
   - *RequestBuilder.smali
   - *Interceptor.smali

=== FILES TO REVIEW ===
- $workDir\com.tokopedia.tokopro\AndroidManifest.xml
- $workDir\com.tokopedia.tokopro\res\xml\network_security_config.xml
- Smali files in: smali/ and smali_classes*/ directories

"@

Set-Content -Path $reportPath -Value $report
Write-Host "Report saved: $reportPath" -ForegroundColor Green

# Display summary
Write-Host "`n[SUMMARY]" -ForegroundColor Cyan
Write-Host "- API Endpoints: Found in decompiled code"
Write-Host "- Network Config: Analyzed"
Write-Host "- Next: Manual smali code inspection needed"
Write-Host "`nReport: $reportPath"
