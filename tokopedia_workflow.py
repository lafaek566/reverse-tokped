#!/usr/bin/env python3
"""
APK Patcher Workflow - Tokopedia Lite Testing Guide
Complete step-by-step untuk reverse engineering Tokopedia Lite

Workflow:
1. Get Tokopedia Lite APK
2. Patch dengan SSL Pinning bypass
3. Setup Burp Suite untuk intercept
4. Install & test di device/emulator
5. Capture & analyze API traffic
"""

import subprocess
import sys
from pathlib import Path

def print_header(title):
    """Print formatted header"""
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")

def print_step(num, title):
    """Print step header"""
    print(f"\n[STEP {num}] {title}")
    print("-" * 70)

def run_command(cmd, shell=False):
    """Run command and show output"""
    print(f">>> {cmd if isinstance(cmd, str) else ' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, shell=shell, capture_output=False, text=True)
        return result.returncode == 0
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    print_header("TOKOPEDIA LITE - REVERSE ENGINEERING WORKFLOW")
    
    # Step 1: Verify environment
    print_step(1, "Environment Setup")
    print("""
Verify all tools are ready:
✓ Python 3.7+
✓ Java JDK
✓ apktool 2.11.1
✓ jarsigner
✓ Debug keystore
✓ Burp Suite / Charles installed
    """)
    
    run_setup = input("\n→ Run setup_check.py? (y/n): ").lower() == 'y'
    if run_setup:
        subprocess.run([sys.executable, "setup_check.py"])
    
    # Step 2: Get APK
    print_step(2, "Get Tokopedia Lite APK")
    print("""
Options:
A) Download from APKPure (https://apkpure.com/tokopedia-lite/)
B) Extract from your device: adb pull /data/app/com.tokopedia.lite*/base.apk
C) Use existing APK file

Paste APK path or 'skip' if already in folder:
    """)
    
    apk_input = input("→ APK path: ").strip()
    
    if apk_input.lower() == 'skip':
        apk_file = "tokopedia-lite.apk"
    else:
        apk_file = apk_input
    
    # Verify APK exists
    apk_path = Path(apk_file)
    if not apk_path.exists():
        print(f"\n✗ APK not found: {apk_file}")
        print("\nWaiting for manual download...")
        print("Once downloaded, name it: tokopedia-lite.apk")
        print("Location:", Path.cwd() / "tokopedia-lite.apk")
        return
    
    print(f"✓ APK found: {apk_file} ({apk_path.stat().st_size / 1024 / 1024:.1f} MB)")
    
    # Step 3: Patch APK
    print_step(3, "Patch APK with SSL Pinning Bypass")
    print(f"""
Running: python apk_patcher.py {apk_file}

This will:
1. Decompile APK
2. Create network_security_config.xml
3. Modify AndroidManifest.xml
4. Rebuild APK
5. Sign APK

Expected time: 2-5 minutes
    """)
    
    run_patcher = input("\n→ Run apk_patcher.py? (y/n): ").lower() == 'y'
    if run_patcher:
        cmd = [sys.executable, "apk_patcher.py", apk_file, "tokopedia-lite-patched.apk"]
        success = run_command(cmd)
        
        if success:
            print("\n✓ Patching successful!")
            print("Output: tokopedia-lite-patched.apk")
        else:
            print("\n✗ Patching failed!")
            return
    
    # Step 4: Setup Device/Emulator
    print_step(4, "Setup Device or Emulator")
    print("""
Option A: Physical Device
1. Connect via USB
2. Enable USB Debugging (Settings → Developer Options)
3. Run: adb devices

Option B: Android Emulator
1. Open Android Device Manager
2. Start emulator
3. Run: adb devices

Once ready:
    """)
    
    input("→ Press ENTER when device is ready...")
    
    # Check ADB
    try:
        result = subprocess.run(["adb", "devices"], capture_output=True, text=True)
        print("\nConnected devices:")
        print(result.stdout)
    except:
        print("⚠ ADB not found in PATH")
    
    # Step 5: Install Patched APK
    print_step(5, "Install Patched APK")
    print("""
Installing tokopedia-lite-patched.apk to device...
    """)
    
    install_apk = input("→ Install APK? (y/n): ").lower() == 'y'
    if install_apk:
        run_command("adb uninstall com.tokopedia.lite", shell=True)
        run_command("adb install tokopedia-lite-patched.apk", shell=True)
        print("\n✓ APK installed!")
    
    # Step 6: Setup Burp Suite
    print_step(6, "Setup Burp Suite / Charles")
    print("""
Configure Proxy on Android Device:
1. Go to WiFi settings
2. Select your network → Advanced
3. Set Proxy: Manual
   - Host: <your-computer-ip>
   - Port: 8080 (or your Burp port)

Install Certificate:
1. Open browser → http://burp or http://proxy-ip:8080
2. Download CA certificate
3. Settings → Security → Install from Storage → Select cert
4. Trust certificate

On Burp Suite:
1. Go to Proxy → Options
2. Listener on 0.0.0.0:8080
3. Enable "Support invisible proxying"
4. Intercept is ON
    """)
    
    input("→ Press ENTER when Burp/device is configured...")
    
    # Step 7: Start Capturing
    print_step(7, "Capture & Analyze Traffic")
    print("""
Now open Tokopedia Lite on device and:
1. Browse products
2. Search
3. Go to profile/account
4. Make some interactions

Watch Burp Suite intercept all requests!

Things to capture:
- API endpoints used
- Authentication headers
- Request/response structure
- Data format (JSON/protobuf/etc)
- Rate limiting
- Security headers
    """)
    
    input("→ Press ENTER when done capturing...")
    
    # Step 8: Analysis
    print_step(8, "Analysis & Documentation")
    print("""
Export findings from Burp:
1. Proxy → HTTP history
2. Select all → Right-click → Save items
3. Format: CSV or JSON

Document:
- API base URL
- Endpoints discovered
- Parameters
- Response format
- Auth mechanism
- Any security findings
    """)
    
    # Summary
    print_header("WORKFLOW COMPLETE!")
    print("""
Deliverables prepared:
✓ Patched APK (SSL bypass enabled)
✓ Burp/Charles traffic logs
✓ API endpoint documentation
✓ Request/response samples
✓ Security findings report

Next steps:
1. Package findings into report
2. Share with client
3. Get approval for findings
4. Deploy patched APK if needed
    """)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nWorkflow cancelled.")
    except Exception as e:
        print(f"\nError: {e}")
