#!/usr/bin/env powershell
# ============================================================================
# TOKOPEDIA BURP TESTING - QUICK START
# ============================================================================
# This script guides you through the testing phases

$colors = @{
    "header" = "Cyan"
    "success" = "Green" 
    "warning" = "Yellow"
    "error" = "Red"
}

function Write-Log {
    param([string]$message, [string]$color = "White")
    Write-Host $message -ForegroundColor $colors[$color]
}

Clear-Host

Write-Log "╔════════════════════════════════════════════════════════════╗" "header"
Write-Log "║  TOKOPEDIA REVERSE ENGINEERING - BURP TESTING QUICKSTART  ║" "header"
Write-Log "╚════════════════════════════════════════════════════════════╝`n" "header"

Write-Log "PROJECT STATUS:`n" "success"
Write-Log "✓ Emulator: Running (emulator-5554)" "success"
Write-Log "✓ Tokopedia App: Installed (com.tokopedia.tokopro)" "success"
Write-Log "✓ APK Patching: Complete (SSL pinning removed)" "success"
Write-Log "✓ Documentation: Updated for Burp Suite" "success"
Write-Log "✓ Setup Scripts: Ready`n" "success"

Write-Log "WHAT'S NEXT:`n" "warning"
Write-Log "1️⃣  Download & Install Burp Suite (5 min)" "warning"
Write-Log "2️⃣  Run automation script (15 min)" "warning"  
Write-Log "3️⃣  Start Tokopedia app (ongoing)" "warning"
Write-Log "4️⃣  Capture & analyze API traffic (1-2 hours)`n" "warning"

Write-Log "CHOOSE AN OPTION:`n" "header"
Write-Log "[1] Install Burp Suite (auto download)" "info"
Write-Log "[2] Run Burp setup script (requires Burp installed)" "info"
Write-Log "[3] View Testing Plan (detailed guide)" "info"
Write-Log "[4] Check emulator status" "info"
Write-Log "[5] Check Tokopedia app" "info"
Write-Log "[6] Exit`n" "info"

$choice = Read-Host "Enter choice (1-6)"

switch ($choice) {
    "1" {
        Write-Log "`n▶ Starting Burp download & installation...\n" "warning"
        .\install_burp.ps1
    }
    
    "2" {
        Write-Log "`n▶ Starting Burp setup automation script...\n" "warning"
        .\burp_setup_final.ps1
    }
    
    "3" {
        Write-Log "`n▶ Opening Testing Plan...\n" "info"
        
        if (Test-Path "TESTING_PLAN.md") {
            # Try to open in VS Code or default text editor
            $editor = Get-Command code -ErrorAction SilentlyContinue
            if ($editor) {
                code TESTING_PLAN.md
            } else {
                Invoke-Item TESTING_PLAN.md
            }
        } else {
            Write-Log "ERROR: TESTING_PLAN.md not found" "error"
        }
    }
    
    "4" {
        Write-Log "`n▶ Checking emulator status...\n" "warning"
        
        $adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"
        
        if (-not (Test-Path $adbPath)) {
            Write-Log "ADB not found at: $adbPath" "error"
            exit 1
        }
        
        Write-Log "Connected devices:" "info"
        & $adbPath devices
        
        Write-Log "`n" "info"
    }
    
    "5" {
        Write-Log "`n▶ Checking Tokopedia app...\n" "warning"
        
        $adbPath = "C:\Users\rriat\AppData\Local\Android\Sdk\platform-tools\adb.exe"
        
        $packages = & $adbPath shell pm list packages | Select-String -Pattern "tokopedia"
        
        if ($packages) {
            Write-Log "Tokopedia apps installed:" "success"
            $packages | ForEach-Object { Write-Log "  $($_)" "info" }
        } else {
            Write-Log "No Tokopedia apps found" "warning"
        }
        
        Write-Log "`n" "info"
    }
    
    "6" {
        Write-Log "Exiting..." "info"
        exit 0
    }
    
    default {
        Write-Log "Invalid choice" "error"
        exit 1
    }
}

Write-Log "`nDone! Next step?" "success"
Read-Host "Press ENTER to continue"
