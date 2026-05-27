#!/usr/bin/env python3
"""
APK Patcher - Developer Guide & API Reference
Panduan untuk developers yang ingin extend atau customize script
"""

# ============================================================================
# ARCHITECTURE OVERVIEW
# ============================================================================

ARCHITECTURE = """
APK PATCHER ARCHITECTURE
========================

┌─────────────────────────────────────────────────────────────┐
│                     apk_patcher.py (MAIN)                   │
│                                                               │
│  Main Functions:                                             │
│  ├─ patch_apk()              [Orchestrator]                 │
│  ├─ decompile_apk()          [Step 1]                       │
│  ├─ create_network_security_config()  [Step 2]              │
│  ├─ modify_android_manifest()         [Step 3]              │
│  ├─ rebuild_apk()            [Step 4]                       │
│  └─ sign_apk()               [Step 5]                       │
│                                                               │
│  Helper Functions:                                           │
│  ├─ run_command()            [Execute shell commands]        │
│  ├─ check_tool_exists()      [Verify tools in PATH]         │
│  ├─ validate_paths()         [Input validation]              │
│  └─ sign_apk_with_*()        [Tool-specific signing]         │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│               SUPPORTING MODULES                         │
├──────────────────────────────────────────────────────────┤
│ setup_check.py          - Environment validation         │
│ config_helper.py        - Advanced customizations        │
│ example_usage.py        - Usage examples & workflows     │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│               EXTERNAL DEPENDENCIES                      │
├──────────────────────────────────────────────────────────┤
│ apktool                 - Android APK decompile/build   │
│ jarsigner / apksigner   - APK signing                    │
│ Java JDK               - jarsigner runtime              │
│ keytool               - Generate debug keystore        │
└──────────────────────────────────────────────────────────┘

DATA FLOW
=========

1. Input: target.apk
   ↓
2. apktool d target.apk
   └─> Extracted folder with AndroidManifest.xml, res/xml/, smali/
   ↓
3. Create res/xml/network_security_config.xml
   └─> XML file that allows user CA certs
   ↓
4. Modify AndroidManifest.xml
   └─> Add android:networkSecurityConfig attribute
   ↓
5. apktool b folder -o patched.apk
   └─> Compiled APK (unsigned)
   ↓
6. jarsigner -keystore debug.keystore patched.apk
   └─> Signed APK (ready to install)
   ↓
7. Output: patched.apk
   ↓
8. adb install patched.apk
   └─> Installed on device

"""

# ============================================================================
# API REFERENCE
# ============================================================================

API_REFERENCE = """
API REFERENCE
=============

MODULE: apk_patcher

MAIN FUNCTIONS
==============

1. patch_apk(apk_path, output_apk='patched.apk', cleanup=True) -> str
   ─────────────────────────────────────────────────────────────
   High-level orchestrator function.
   
   Args:
       apk_path (str)      : Path to target APK
       output_apk (str)    : Output filename (default: patched.apk)
       cleanup (bool)      : Delete decompiled folder after build
   
   Returns:
       str : Path to patched APK
   
   Raises:
       FileNotFoundError   : APK not found
       RuntimeError        : Tool missing or operation failed
   
   Example:
       >>> result = patch_apk('myapp.apk')
       >>> print(result)
       'patched.apk'


2. decompile_apk(apk_path) -> str
   ───────────────────────────────
   Decompress APK using apktool.
   
   Args:
       apk_path (str) : Path to APK
   
   Returns:
       str : Directory name of decompiled folder
   
   Raises:
       RuntimeError : apktool not found or decompile failed
   
   Example:
       >>> folder = decompile_apk('myapp.apk')
       >>> print(folder)
       'myapp'


3. create_network_security_config(output_dir) -> Path
   ──────────────────────────────────────────────────
   Create network_security_config.xml in res/xml/.
   
   Args:
       output_dir (str) : Decompiled folder path
   
   Returns:
       Path : Path object to created file
   
   Raises:
       RuntimeError : File creation failed
   
   Example:
       >>> config_path = create_network_security_config('myapp')
       >>> print(config_path)
       WindowsPath('myapp/res/xml/network_security_config.xml')


4. modify_android_manifest(output_dir) -> None
   ──────────────────────────────────────────
   Add networkSecurityConfig attribute to <application> tag.
   
   Args:
       output_dir (str) : Decompiled folder path
   
   Raises:
       FileNotFoundError : AndroidManifest.xml not found
       RuntimeError      : XML modification failed
   
   Example:
       >>> modify_android_manifest('myapp')
       >>> # AndroidManifest.xml now has networkSecurityConfig


5. rebuild_apk(output_dir, output_apk='patched.apk') -> str
   ──────────────────────────────────────────────────────
   Repack decompiled folder to APK using apktool.
   
   Args:
       output_dir (str)   : Decompiled folder
       output_apk (str)   : Output APK filename
   
   Returns:
       str : Path to rebuilt APK
   
   Raises:
       RuntimeError : apktool not found or build failed
   
   Example:
       >>> apk_path = rebuild_apk('myapp')
       >>> print(apk_path)
       'patched.apk'


6. sign_apk(apk_path) -> None
   ──────────────────────────
   Sign APK using available tool (jarsigner/apksigner).
   
   Args:
       apk_path (str) : Path to APK to sign
   
   Raises:
       RuntimeError      : No signing tool found
       FileNotFoundError : Debug keystore missing
   
   Example:
       >>> sign_apk('patched.apk')
       >>> # APK now signed and ready


HELPER FUNCTIONS
================

7. check_tool_exists(tool_name) -> bool
   ──────────────────────────────────
   Check if tool available in PATH.
   
   Args:
       tool_name (str) : Tool name (e.g., 'apktool')
   
   Returns:
       bool : True if tool exists in PATH
   
   Example:
       >>> check_tool_exists('apktool')
       True


8. run_command(command, cwd=None) -> Tuple[int, str, str]
   ──────────────────────────────────────────────────────
   Execute shell command and capture output.
   
   Args:
       command (list) : Command as list ['cmd', 'arg1', 'arg2']
       cwd (str)      : Working directory
   
   Returns:
       Tuple : (return_code, stdout, stderr)
   
   Raises:
       FileNotFoundError : Command not found
   
   Example:
       >>> code, out, err = run_command(['apktool', 'd', 'app.apk'])
       >>> print(f"Exit code: {code}")


9. validate_paths(apk_path) -> Path
   ─────────────────────────────────
   Validate and return absolute path to APK.
   
   Args:
       apk_path (str) : Input APK path
   
   Returns:
       Path : Absolute path object
   
   Raises:
       FileNotFoundError : APK not found
       ValueError        : Not .apk extension


INTERNAL: Signing Tools
=======================

10. find_signing_tool() -> Tuple[str, str]
    ──────────────────────────────────────
    Find available signing tool (apksigner or jarsigner).
    
    Returns:
        Tuple : (tool_name, full_path)


11. sign_apk_with_jarsigner(apk_path) -> None
    ─────────────────────────────────────────
    Sign using jarsigner (Java JDK).


12. sign_apk_with_apksigner(apk_path) -> None
    ────────────────────────────────────────
    Sign using apksigner (Android SDK).

"""

# ============================================================================
# CUSTOMIZATION GUIDE
# ============================================================================

CUSTOMIZATION_GUIDE = """
CUSTOMIZATION GUIDE
===================

How to extend apk_patcher for custom use cases.


OPTION 1: Using Hooks (Simple)
===============================

Modify apk_patcher.py step 3.5 area:

    # Step 3: Modify manifest
    modify_android_manifest(decompiled_dir)
    
    # [ADD YOUR CODE HERE]
    print("Custom modification point!")
    
    # Example: Add permissions
    manifest_path = Path(decompiled_dir) / 'AndroidManifest.xml'
    
    # Step 4: Rebuild APK
    rebuilt_apk = rebuild_apk(decompiled_dir, output_apk)


OPTION 2: Using config_helper.py (Recommended)
===============================================

Already provides:
- StringsXMLModifier    → Modify app strings
- PermissionModifier    → Add permissions
- ResourceModifier      → Work with resources
- NetworkConfigGenerator → Custom network configs

Example in your code:

    from config_helper import StringsXMLModifier
    
    decompiled = decompile_apk('app.apk')
    
    # Modify API endpoint
    StringsXMLModifier.modify_strings(decompiled, {
        'api_base_url': 'https://staging.example.com',
        'debug_mode': 'true'
    })
    
    # Continue normal flow...
    modify_android_manifest(decompiled)
    rebuilt = rebuild_apk(decompiled)


OPTION 3: Create Subclass (Advanced)
===================================

from apk_patcher import *

class CustomAPKPatcher:
    '''My custom APK patcher'''
    
    def __init__(self, apk_path):
        self.apk_path = apk_path
        self.decompiled_dir = None
    
    def run(self):
        # Step 1-3: Standard flow
        self.decompiled_dir = decompile_apk(self.apk_path)
        create_network_security_config(self.decompiled_dir)
        modify_android_manifest(self.decompiled_dir)
        
        # Step X: Custom modifications
        self.inject_logging()
        self.patch_analytics()
        self.modify_build_config()
        
        # Step 4-5: Rebuild & sign
        rebuilt = rebuild_apk(self.decompiled_dir)
        sign_apk(rebuilt)
        
        return rebuilt
    
    def inject_logging(self):
        '''Custom: Add logging'''
        print("Injecting logging...")
    
    def patch_analytics(self):
        '''Custom: Remove analytics'''
        print("Patching analytics...")
    
    def modify_build_config(self):
        '''Custom: Modify build config'''
        print("Modifying build config...")


# Usage:
patcher = CustomAPKPatcher('myapp.apk')
result = patcher.run()


OPTION 4: Plugin System (Most Flexible)
=======================================

class APKPatcherPlugin:
    '''Base plugin class'''
    
    def execute(self, decompiled_dir):
        '''Override in subclass'''
        raise NotImplementedError

class RemoveAdNetworkPlugin(APKPatcherPlugin):
    def execute(self, decompiled_dir):
        # Remove ad network libraries
        pass

class InjectLoggingPlugin(APKPatcherPlugin):
    def execute(self, decompiled_dir):
        # Add logging everywhere
        pass

# Usage:
plugins = [RemoveAdNetworkPlugin(), InjectLoggingPlugin()]
patcher = APKPatcher('app.apk', plugins=plugins)
result = patcher.patch()


COMMON MODIFICATIONS
====================

1. Change API Endpoint
   └─ Use StringsXMLModifier.modify_strings()

2. Add Permissions
   └─ Use PermissionModifier.add_permission()

3. Remove Analytics
   └─ Use ResourceModifier.remove_analytics()

4. Allow Specific Domain Only
   └─ Use NetworkConfigGenerator.generate_domain_specific()

5. Inject Logging Code
   └─ Modify smali files directly (advanced)

6. Disable ProGuard Obfuscation
   └─ Keep original structure from apktool decompile

"""

# ============================================================================
# ERROR HANDLING GUIDE
# ============================================================================

ERROR_HANDLING_GUIDE = """
ERROR HANDLING GUIDE
====================

Common Exceptions and How to Handle


1. FileNotFoundError
   ─────────────────
   When: APK not found, manifest missing, etc.
   
   How to fix:
   ├─ Check file path is correct
   ├─ Use absolute paths (not relative)
   └─ Verify file exists: Path(file).exists()


2. RuntimeError
   ────────────
   When: apktool failed, signing failed, etc.
   
   How to fix:
   ├─ Check tool is installed (run setup_check.py)
   ├─ Check PATH environment variable
   ├─ Try tool manually: apktool --version
   └─ Check file permissions


3. xml.etree.ElementTree.ParseError
   ────────────────────────────────
   When: XML file is malformed
   
   How to fix:
   ├─ Verify AndroidManifest.xml is valid XML
   ├─ Try with fresh APK (not re-patched)
   └─ Check XML encoding (UTF-8)


4. subprocess.TimeoutExpired
   ───────────────────────
   When: Command takes too long
   
   How to fix:
   ├─ Increase timeout in run_command()
   ├─ Check disk space (apktool needs space)
   └─ Try with smaller APK


Custom Error Handling Example:

    try:
        result = patch_apk('myapp.apk')
    
    except FileNotFoundError:
        print("APK file not found!")
        print("Make sure myapp.apk exists")
    
    except RuntimeError as e:
        print(f"Runtime error: {e}")
        print("Run: python setup_check.py")
    
    except Exception as e:
        print(f"Unexpected error: {e}")
        import traceback
        traceback.print_exc()

"""

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

PERFORMANCE_GUIDE = """
PERFORMANCE OPTIMIZATION
========================

Apktool decompile/repack dapat lambat untuk APK besar.
Berikut tips untuk optimize:


1. Disable Optimization During Development
   ──────────────────────────────────────────
   Set cleanup=False to reuse decompiled folder:
   
   patch_apk('app.apk', cleanup=False)
   
   Kedua kalinya (jika app.apk sama):
   - Cek apakah folder sudah ada
   - Skip decompile, langsung modify


2. Parallel Processing
   ───────────────────
   Untuk multiple APKs, gunakan threading:
   
   from concurrent.futures import ThreadPoolExecutor
   
   def patch_one(apk):
       return patch_apk(apk)
   
   with ThreadPoolExecutor(max_workers=2) as executor:
       results = list(executor.map(patch_one, apk_files))


3. Reduce APK Size
   ────────────────
   Remove unused resources sebelum patching:
   
   - Use Android Studio analyzer
   - Remove large asset files
   - Use resource minification


4. Use Emulator/Lighter Alternative
   ─────────────────────────────────
   Testing bisa di emulator lebih cepat:
   
   - Android Emulator
   - Genymotion
   - BlueStacks


5. Caching Layer
   ───────────────
   Cache sudah-di-patch APKs:
   
   import hashlib
   
   def get_cache_key(apk_path):
       with open(apk_path, 'rb') as f:
           return hashlib.md5(f.read()).hexdigest()
   
   cache = {}
   
   def cached_patch(apk):
       key = get_cache_key(apk)
       if key in cache:
           return cache[key]
       
       result = patch_apk(apk)
       cache[key] = result
       return result

"""

# ============================================================================
# MAIN OUTPUT
# ============================================================================

if __name__ == '__main__':
    print(ARCHITECTURE)
    print("\n" + "="*80 + "\n")
    print(API_REFERENCE)
    print("\n" + "="*80 + "\n")
    print(CUSTOMIZATION_GUIDE)
    print("\n" + "="*80 + "\n")
    print(ERROR_HANDLING_GUIDE)
    print("\n" + "="*80 + "\n")
    print(PERFORMANCE_GUIDE)
    print("\n" + "="*80 + "\n")
    print("""
NEXT STEPS:
===========

1. Read this file carefully
2. Check example_usage.py for examples
3. Check config_helper.py for customization hooks
4. Start with simple patching (see QUICKSTART.md)
5. Gradually add customizations as needed

For detailed docs:
- README.md        → Full reference
- QUICKSTART.md    → Quick start
- This file        → Developer guide

Questions? Check if similar issue in other files!
    """)
