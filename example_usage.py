#!/usr/bin/env python3
"""
Example Usage - APK Patcher Script
Menunjukkan berbagai cara menggunakan apk_patcher.py

Run: python example_usage.py
"""

import os
from pathlib import Path
from apk_patcher import (
    patch_apk,
    decompile_apk,
    create_network_security_config,
    modify_android_manifest,
    rebuild_apk,
    sign_apk
)

# ============================================================================
# CONTOH 1: Simple Usage - Patch APK dengan default output
# ============================================================================

def example_simple():
    """
    Contoh paling sederhana: Input APK → Output patched.apk
    """
    print("\n" + "="*70)
    print("EXAMPLE 1: Simple Patching")
    print("="*70)
    
    try:
        # Asumsikan target.apk ada di current directory
        result = patch_apk('target.apk')
        print(f"Success! Output: {result}")
        
    except Exception as e:
        print(f"Error: {e}")


# ============================================================================
# CONTOH 2: Custom Output Name
# ============================================================================

def example_custom_output():
    """
    Patch dengan custom output name
    """
    print("\n" + "="*70)
    print("EXAMPLE 2: Custom Output Name")
    print("="*70)
    
    try:
        result = patch_apk(
            'target.apk',
            'my_app_ssl_bypass.apk',
            cleanup=False  # Keep decompiled folder
        )
        print(f"Success! Output: {result}")
        
    except Exception as e:
        print(f"Error: {e}")


# ============================================================================
# CONTOH 3: Manual Step-by-Step (untuk advanced users)
# ============================================================================

def example_manual_steps():
    """
    Kontrol setiap step secara manual
    Berguna jika ingin add custom modifications
    """
    print("\n" + "="*70)
    print("EXAMPLE 3: Manual Step-by-Step Control")
    print("="*70)
    
    try:
        apk_file = 'target.apk'
        
        # Step 1: Decompile
        print("\n>> STEP 1: Decompiling APK...")
        decompiled_dir = decompile_apk(apk_file)
        print(f"   Decompiled to: {decompiled_dir}/")
        
        # Step 2: Modify network config
        print("\n>> STEP 2: Creating network security config...")
        config_file = create_network_security_config(decompiled_dir)
        print(f"   Created: {config_file}")
        
        # Step 3: Modify manifest
        print("\n>> STEP 3: Modifying AndroidManifest.xml...")
        modify_android_manifest(decompiled_dir)
        print(f"   Modified: {decompiled_dir}/AndroidManifest.xml")
        
        # [OPTIONAL] Step 3.5: Add custom modifications here
        print("\n>> STEP 3.5: [Opportunity for custom modifications]")
        print("   - Example: Remove analytics")
        print("   - Example: Inject custom code")
        print("   - Example: Modify strings.xml")
        
        # Step 4: Rebuild APK
        print("\n>> STEP 4: Rebuilding APK...")
        rebuilt_apk = rebuild_apk(decompiled_dir, 'my_custom_patched.apk')
        print(f"   Rebuilt: {rebuilt_apk}")
        
        # Step 5: Sign APK
        print("\n>> STEP 5: Signing APK...")
        sign_apk(rebuilt_apk)
        print(f"   Signed: {rebuilt_apk}")
        
        print(f"\n✓ All steps completed!")
        
    except Exception as e:
        print(f"Error: {e}")


# ============================================================================
# CONTOH 4: Batch Processing Multiple APKs
# ============================================================================

def example_batch_processing():
    """
    Patch multiple APKs sekaligus
    """
    print("\n" + "="*70)
    print("EXAMPLE 4: Batch Processing")
    print("="*70)
    
    apk_files = [
        'app1.apk',
        'app2.apk',
        'app3.apk'
    ]
    
    results = []
    
    for apk_file in apk_files:
        if not Path(apk_file).exists():
            print(f"⚠ Skipping {apk_file} (not found)")
            continue
        
        try:
            print(f"\n>> Processing {apk_file}...")
            output_name = Path(apk_file).stem + '_patched.apk'
            result = patch_apk(apk_file, output_name)
            results.append((apk_file, 'SUCCESS', result))
            
        except Exception as e:
            print(f"✗ Failed: {e}")
            results.append((apk_file, 'FAILED', str(e)))
    
    # Summary
    print("\n" + "="*70)
    print("BATCH PROCESSING SUMMARY")
    print("="*70)
    
    for apk, status, detail in results:
        symbol = "✓" if status == "SUCCESS" else "✗"
        print(f"{symbol} {apk:20} - {status:10} - {detail}")


# ============================================================================
# CONTOH 5: Advanced - Error Handling
# ============================================================================

def example_advanced_error_handling():
    """
    Menangani berbagai error scenarios
    """
    print("\n" + "="*70)
    print("EXAMPLE 5: Advanced Error Handling")
    print("="*70)
    
    apk_file = 'target.apk'
    
    try:
        # Validate input
        if not Path(apk_file).exists():
            raise FileNotFoundError(f"APK not found: {apk_file}")
        
        if not Path(apk_file).suffix.lower() == '.apk':
            raise ValueError(f"Not an APK file: {apk_file}")
        
        # Run patcher
        print(f"Patching {apk_file}...")
        result = patch_apk(apk_file)
        print(f"✓ Success: {result}")
        
    except FileNotFoundError as e:
        print(f"✗ File Error: {e}")
        print("  Make sure your APK file exists in current directory")
        
    except ValueError as e:
        print(f"✗ Validation Error: {e}")
        print("  File must be a valid .apk file")
        
    except RuntimeError as e:
        print(f"✗ Runtime Error: {e}")
        print("  Check if apktool, jarsigner, and Java are installed")
        
    except Exception as e:
        print(f"✗ Unexpected Error: {e}")
        print("  Run setup_check.py to verify your environment")


# ============================================================================
# CONTOH 6: Workflow untuk Security Testing
# ============================================================================

def example_security_testing_workflow():
    """
    Complete workflow untuk security testing dengan Burp Suite
    """
    print("\n" + "="*70)
    print("EXAMPLE 6: Security Testing Workflow")
    print("="*70)
    
    workflow = """
    STEP 1: Persiapan
    ├─ Start Burp Suite Community (or Professional)
    ├─ Set proxy ke localhost:8080
    ├─ Enable SSL interception
    └─ Export CA certificate to file
    
    STEP 2: Setup Android Device/Emulator
    ├─ Run: adb devices
    ├─ Configure WiFi proxy settings
    │  └─ Settings > Network > Proxy > Manual
    │     Host: <your-computer-ip>
    │     Port: 8080
    └─ Install Burp CA certificate
       └─ Settings > Security > Install Certificate > (select Burp CA file)
    
    STEP 3: Patch APK
    ├─ Run: python apk_patcher.py target.apk
    └─ Output: patched.apk
    
    STEP 4: Install Patched APK
    ├─ Run: adb uninstall com.example.app  (if exists)
    ├─ Run: adb install patched.apk
    └─ Verify installation
    
    STEP 5: Intercept Traffic
    ├─ Open app on device
    ├─ Monitor requests in Burp Suite
    ├─ Intercept & modify requests
    ├─ Check Burp History for all captured traffic
    └─ Analyze API endpoints
    
    STEP 6: Analyze & Report
    ├─ Review API request/response patterns
    ├─ Identify authentication mechanisms
    ├─ Check for sensitive data exposure
    ├─ Document endpoints & parameters
    └─ Generate report
    """
    
    print(workflow)


# ============================================================================
# CONTOH 7: Troubleshooting Guide
# ============================================================================

def example_troubleshooting():
    """
    Common issues dan solutions
    """
    print("\n" + "="*70)
    print("EXAMPLE 7: Troubleshooting Guide")
    print("="*70)
    
    issues = {
        "apktool not found": {
            "cause": "apktool tidak di PATH",
            "solution": [
                "1. Download dari https://ibotpeaches.github.io/Apktool/",
                "2. Extract ke C:\\apktool\\",
                "3. Add to Windows PATH:",
                "   setx PATH \"%PATH%;C:\\apktool\"",
                "4. Restart terminal"
            ]
        },
        "jarsigner not found": {
            "cause": "Java JDK tidak installed atau tidak di PATH",
            "solution": [
                "1. Install Java JDK (not JRE)",
                "2. Add JDK bin to PATH:",
                "   setx PATH \"%PATH%;C:\\Program Files\\Java\\jdk-21\\bin\"",
                "3. Restart terminal"
            ]
        },
        "APK signing failed": {
            "cause": "Debug keystore tidak ada atau corrupt",
            "solution": [
                "1. Delete: C:\\.android\\debug.keystore",
                "2. Run setup_check.py untuk recreate"
            ]
        },
        "APK installation fails": {
            "cause": "APK incompatible atau sudah terinstall",
            "solution": [
                "1. Uninstall: adb uninstall com.example.app",
                "2. Re-install: adb install patched.apk",
                "3. Check: adb logcat | findstr app-name"
            ]
        }
    }
    
    for issue, details in issues.items():
        print(f"\n► {issue}")
        print(f"  Cause: {details['cause']}")
        print("  Solution:")
        for step in details['solution']:
            print(f"    {step}")


# ============================================================================
# MENU UTAMA
# ============================================================================

def main():
    """Main menu"""
    print("\n" + "="*70)
    print("APK PATCHER - EXAMPLE USAGE")
    print("="*70)
    print("""
Choose an example:
1. Simple Patching
2. Custom Output Name
3. Manual Step-by-Step
4. Batch Processing
5. Advanced Error Handling
6. Security Testing Workflow
7. Troubleshooting Guide
0. Exit
    """)
    
    choice = input("Enter choice (0-7): ").strip()
    
    examples = {
        '1': example_simple,
        '2': example_custom_output,
        '3': example_manual_steps,
        '4': example_batch_processing,
        '5': example_advanced_error_handling,
        '6': example_security_testing_workflow,
        '7': example_troubleshooting,
        '0': lambda: print("Goodbye!")
    }
    
    if choice in examples:
        examples[choice]()
    else:
        print("Invalid choice!")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nExiting...")
    except Exception as e:
        print(f"Error: {e}")
