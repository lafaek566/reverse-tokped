#!/usr/bin/env python3
"""
Download Tokopedia Lite APK from multiple sources
Choose the most reliable method available
"""

import subprocess
import sys
from pathlib import Path
import time

def print_header(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")

def download_via_curl(url, output_file):
    """Try downloading using curl"""
    try:
        print(f"Attempting download with curl: {url}")
        cmd = f'curl -L -o "{output_file}" "{url}" -m 300'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0 and Path(output_file).exists():
            return True
    except:
        pass
    return False

def download_via_powershell(url, output_file):
    """Try downloading using PowerShell"""
    try:
        print(f"Attempting download with PowerShell: {url}")
        ps_cmd = f'''
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "{url}" -OutFile "{output_file}" -TimeoutSec 300 -UseBasicParsing
'''
        result = subprocess.run(['powershell', '-Command', ps_cmd], capture_output=True, text=True, timeout=300)
        if result.returncode == 0 and Path(output_file).exists():
            return True
    except:
        pass
    return False

def main():
    print_header("TOKOPEDIA LITE APK DOWNLOADER")
    
    output_file = Path("tokopedia-lite.apk")
    
    # Check if already exists
    if output_file.exists():
        size_mb = output_file.stat().st_size / 1024 / 1024
        print(f"✓ APK already exists: {output_file} ({size_mb:.1f} MB)")
        return
    
    # List of sources to try (from public repositories)
    sources = [
        {
            "name": "APKPure Direct",
            "url": "https://d.apkpure.com/b/XAPK/com.tokopedia.lite?versionCode=500",
            "description": "APKPure latest version"
        },
        {
            "name": "APK from GitHub",
            "url": "https://github.com/android-apps/tokopedia-lite/releases/download/latest/app-release.apk",
            "description": "GitHub releases (if available)"
        },
    ]
    
    print("\nAvailable download sources:\n")
    for i, source in enumerate(sources, 1):
        print(f"{i}. {source['name']}")
        print(f"   {source['description']}")
        print(f"   URL: {source['url'][:60]}...\n")
    
    print("\nNote: You can also manually download from:")
    print("- APKPure: https://apkpure.com/tokopedia-lite/")
    print("- APKMirror: https://www.apkmirror.com/")
    print("- Or extract from device: adb pull /data/app/com.tokopedia.lite*/base.apk\n")
    
    # Try automatic download
    for source in sources:
        print(f"\n{'='*70}")
        print(f"Trying: {source['name']}")
        print(f"{'='*70}")
        
        # Try curl first
        if download_via_curl(source['url'], output_file):
            size_mb = output_file.stat().st_size / 1024 / 1024
            if size_mb > 10:  # APK should be at least 10MB
                print(f"\n✓ SUCCESS! Downloaded: {output_file} ({size_mb:.1f} MB)")
                return
            else:
                print(f"✗ Downloaded file too small ({size_mb:.1f} MB), trying next source...")
                output_file.unlink()
        
        # Try PowerShell
        if download_via_powershell(source['url'], output_file):
            size_mb = output_file.stat().st_size / 1024 / 1024
            if size_mb > 10:
                print(f"\n✓ SUCCESS! Downloaded: {output_file} ({size_mb:.1f} MB)")
                return
            else:
                print(f"✗ Downloaded file too small ({size_mb:.1f} MB), trying next source...")
                output_file.unlink()
        
        print(f"✗ Failed to download from {source['name']}")
        time.sleep(2)
    
    # Manual instructions
    print(f"\n{'='*70}")
    print("MANUAL DOWNLOAD REQUIRED")
    print(f"{'='*70}\n")
    
    print("""
Automatic download failed. Please download manually:

OPTION A: From APKPure
1. Go to: https://apkpure.com/tokopedia-lite/
2. Click "Download APK"
3. Save as: tokopedia-lite.apk
4. Place in: C:\\Users\\rriat\\OneDrive\\Dokumen\\test\\testing\\

OPTION B: From Device
1. Connect Android device
2. Run in PowerShell:
   adb pull /data/app/com.tokopedia.lite/base.apk tokopedia-lite.apk

OPTION C: From APKMirror
1. Go to: https://www.apkmirror.com/
2. Search for "Tokopedia Lite"
3. Download latest version
4. Rename to: tokopedia-lite.apk

Once downloaded, run:
  py -3 tokopedia_workflow.py
    """)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nCancelled.")
    except Exception as e:
        print(f"\nError: {e}")
