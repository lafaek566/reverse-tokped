#!/usr/bin/env python3
"""
Setup script untuk APK Patcher di Windows
Automatically check dan setup required tools
"""

import os
import sys
import subprocess
import shutil
import winreg
from pathlib import Path

# Color output
class Color:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'

def print_header():
    print(f"\n{Color.BLUE}{'='*70}{Color.END}")
    print(f"{Color.BLUE}APK PATCHER SETUP - Windows{Color.END}")
    print(f"{Color.BLUE}{'='*70}{Color.END}\n")

def print_success(msg):
    print(f"{Color.GREEN}✓ {msg}{Color.END}")

def print_error(msg):
    print(f"{Color.RED}✗ {msg}{Color.END}")

def print_warning(msg):
    print(f"{Color.YELLOW}⚠ {msg}{Color.END}")

def print_info(msg):
    print(f"{Color.BLUE}ℹ {msg}{Color.END}")

def check_tool(tool_name):
    """Check if tool exists in PATH"""
    return shutil.which(tool_name) is not None

def check_python():
    """Verify Python version"""
    print(f"\n{Color.BLUE}[1/5] Checking Python...{Color.END}")
    
    version_info = sys.version_info
    version = f"{version_info.major}.{version_info.minor}.{version_info.micro}"
    
    if version_info.major < 3 or (version_info.major == 3 and version_info.minor < 7):
        print_error(f"Python {version} (minimum 3.7 required)")
        return False
    
    print_success(f"Python {version}")
    return True

def check_java():
    """Check Java installation"""
    print(f"\n{Color.BLUE}[2/5] Checking Java...{Color.END}")
    
    if not check_tool('java'):
        print_error("Java not found in PATH")
        print_warning("Install from: https://www.oracle.com/java/technologies/downloads/")
        print_warning("Or use: choco install openjdk (if you have Chocolatey)")
        return False
    
    # Get version
    try:
        result = subprocess.run(['java', '-version'], capture_output=True, text=True)
        version_output = result.stderr.split('\n')[0]
        print_success(f"Java found: {version_output}")
        return True
    except:
        print_warning("Java found but could not verify version")
        return True

def check_jarsigner():
    """Check jarsigner (comes with Java)"""
    print(f"\n{Color.BLUE}[3/5] Checking jarsigner...{Color.END}")
    
    if not check_tool('jarsigner'):
        print_warning("jarsigner not found in PATH")
        print_warning("This comes with Java JDK. Make sure JDK (not JRE) is installed")
        return False
    
    print_success("jarsigner found")
    return True

def check_apktool():
    """Check apktool installation"""
    print(f"\n{Color.BLUE}[4/5] Checking apktool...{Color.END}")
    
    # Method 1: Check in PATH
    if check_tool('apktool'):
        print_success("apktool found in PATH")
        return True
    
    # Method 2: Check if jar exists
    jar_path = Path("C:/apktool/apktool.jar")
    if jar_path.exists():
        print_success(f"apktool.jar found at {jar_path} ({jar_path.stat().st_size / 1024 / 1024:.1f} MB)")
        return True
    
    # Method 3: Try Windows alternative path
    jar_path_win = Path("C:\\apktool\\apktool.jar")
    if jar_path_win.exists():
        print_success(f"apktool.jar found at {jar_path_win}")
        return True
    
    print_error("apktool not found")
    print_info("Installation options:")
    print("  A) Download from https://ibotpeaches.github.io/Apktool/")
    print("     Extract to: C:\\apktool\\")
    print("  B) Use package manager:")
    print("     - scoop: scoop install apktool")
    print("     - chocolatey: choco install apktool")
    
    return False

def check_debug_keystore():
    """Check debug keystore for signing"""
    print(f"\n{Color.BLUE}[5/5] Checking debug keystore...{Color.END}")
    
    keystore_path = Path.home() / '.android' / 'debug.keystore'
    
    if keystore_path.exists():
        print_success(f"Debug keystore found at {keystore_path}")
        return True
    
    print_warning(f"Debug keystore not found at {keystore_path}")
    print_info("Creating debug keystore...")
    
    # Create .android folder
    keystore_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Create keystore using keytool
    try:
        cmd = [
            'keytool',
            '-genkeypair', '-v',
            '-keystore', str(keystore_path),
            '-alias', 'androiddebugkey',
            '-keyalg', 'RSA',
            '-keysize', '2048',
            '-validity', '10000',
            '-storepass', 'android',
            '-keypass', 'android',
            '-dname', 'CN=Android Debug,O=Android,C=US'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0 and keystore_path.exists():
            print_success(f"Debug keystore created at {keystore_path}")
            return True
        else:
            print_error(f"Failed to create keystore: {result.stderr}")
            return False
            
    except Exception as e:
        print_error(f"Error creating keystore: {e}")
        return False

def add_to_path(path_to_add):
    """Add directory to Windows PATH"""
    try:
        # Open registry
        reg_path = r'Environment'
        registry = winreg.ConnectRegistry(None, winreg.HKEY_CURRENT_USER)
        key = winreg.OpenKey(registry, reg_path, 0, winreg.KEY_ALL_ACCESS)
        
        # Get current PATH
        current_path, _ = winreg.QueryValueEx(key, 'Path')
        
        # Check if already in PATH
        if path_to_add in current_path:
            return True
        
        # Add new path
        new_path = current_path + ';' + path_to_add
        winreg.SetValueEx(key, 'Path', 0, winreg.REG_EXPAND_SZ, new_path)
        winreg.CloseKey(key)
        
        return True
    except Exception as e:
        print_error(f"Could not modify registry: {e}")
        return False

def setup_summary(results):
    """Print setup summary"""
    print(f"\n{Color.BLUE}{'='*70}{Color.END}")
    print(f"{Color.BLUE}SETUP SUMMARY{Color.END}")
    print(f"{Color.BLUE}{'='*70}{Color.END}\n")
    
    all_ok = True
    
    checks = [
        ("Python", results['python']),
        ("Java", results['java']),
        ("jarsigner", results['jarsigner']),
        ("apktool", results['apktool']),
        ("Debug Keystore", results['keystore'])
    ]
    
    for name, status in checks:
        if status:
            print_success(f"{name:20} - OK")
        else:
            print_error(f"{name:20} - MISSING")
            all_ok = False
    
    print()
    
    if all_ok:
        print_success("All checks passed! You're ready to use apk_patcher.py")
        print_info("Usage: python apk_patcher.py target.apk [output.apk]")
    else:
        print_error("Some requirements are missing. Please install them manually.")
        print_info("See README.md for detailed setup instructions")
    
    print(f"\n{Color.BLUE}{'='*70}{Color.END}\n")
    
    return all_ok

def main():
    """Main setup routine"""
    print_header()
    
    results = {
        'python': check_python(),
        'java': check_java(),
        'jarsigner': check_jarsigner(),
        'apktool': check_apktool(),
        'keystore': check_debug_keystore()
    }
    
    all_ok = setup_summary(results)
    
    if not all_ok:
        sys.exit(1)
    else:
        print_success("Setup verification complete!")
        return 0

if __name__ == '__main__':
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print_warning("\nSetup cancelled by user")
        sys.exit(1)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
