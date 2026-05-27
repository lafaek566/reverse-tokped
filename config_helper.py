#!/usr/bin/env python3
"""
Advanced Configuration & Custom Modifications Helper
Untuk custom modifications terhadap APK yang di-patch
"""

from pathlib import Path
from xml.etree import ElementTree as ET
import logging

logger = logging.getLogger(__name__)

# ============================================================================
# STRING.XML MODIFICATIONS
# ============================================================================

class StringsXMLModifier:
    """
    Modifikasi strings.xml di dalam APK
    Berguna untuk mengganti text, URL, API endpoints
    """
    
    @staticmethod
    def modify_strings(decompiled_dir: str, replacements: dict):
        """
        Modifikasi values dalam strings.xml
        
        Args:
            decompiled_dir: Folder hasil decompile
            replacements: Dict {string_name: new_value}
        
        Example:
            modify_strings('app', {
                'api_endpoint': 'https://debug.example.com',
                'api_key': 'test_key_12345'
            })
        """
        strings_path = Path(decompiled_dir) / 'res' / 'values' / 'strings.xml'
        
        if not strings_path.exists():
            logger.warning(f"strings.xml not found: {strings_path}")
            return
        
        try:
            tree = ET.parse(strings_path)
            root = tree.getroot()
            
            for string_name, new_value in replacements.items():
                # Find string with this name
                for elem in root.findall('string'):
                    if elem.get('name') == string_name:
                        elem.text = new_value
                        logger.info(f"✓ Updated string '{string_name}' → '{new_value}'")
                        break
            
            tree.write(strings_path, encoding='utf-8', xml_declaration=True)
            logger.info(f"✓ strings.xml modified: {strings_path}")
            
        except Exception as e:
            logger.error(f"Error modifying strings.xml: {e}")


# ============================================================================
# SMALI CODE INJECTION
# ============================================================================

class SmaliModifier:
    """
    Inject/modify Smali code (compiled Android code)
    Advanced usage untuk custom behavior injection
    """
    
    @staticmethod
    def disable_ssl_verification(decompiled_dir: str):
        """
        Disable SSL verification di aplikasi
        WARNING: More invasive, tidak recommended
        
        Better approach: Use network_security_config.xml (sudah di-handle)
        """
        logger.warning("Direct SSL disabling via Smali is risky")
        logger.info("Recommended: Use network_security_config.xml method")
    
    @staticmethod
    def list_smali_files(decompiled_dir: str):
        """
        List semua .smali files untuk analysis
        """
        smali_dir = Path(decompiled_dir) / 'smali'
        
        if not smali_dir.exists():
            logger.error(f"smali folder not found: {smali_dir}")
            return []
        
        smali_files = list(smali_dir.rglob('*.smali'))
        logger.info(f"Found {len(smali_files)} .smali files")
        
        return smali_files


# ============================================================================
# PERMISSION MODIFICATIONS
# ============================================================================

class PermissionModifier:
    """
    Modifikasi permissions di AndroidManifest.xml
    Berguna untuk allow additional capabilities
    """
    
    @staticmethod
    def add_permission(manifest_path: str, permission: str):
        """
        Tambah permission ke AndroidManifest
        
        Args:
            manifest_path: Path ke AndroidManifest.xml
            permission: Permission name (e.g., 'android.permission.INTERNET')
        
        Example:
            add_permission('AndroidManifest.xml', 
                          'android.permission.READ_EXTERNAL_STORAGE')
        """
        try:
            tree = ET.parse(manifest_path)
            root = tree.getroot()
            
            # Daftarkan namespace
            ET.register_namespace('android', 'http://schemas.android.com/apk/res/android')
            
            ns = {'android': 'http://schemas.android.com/apk/res/android'}
            
            # Check if permission already exists
            for perm in root.findall('uses-permission', ns):
                if perm.get('{http://schemas.android.com/apk/res/android}name') == permission:
                    logger.info(f"Permission already exists: {permission}")
                    return
            
            # Add new permission
            uses_perm = ET.Element('uses-permission')
            uses_perm.set('{http://schemas.android.com/apk/res/android}name', permission)
            root.insert(0, uses_perm)
            
            tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
            logger.info(f"✓ Permission added: {permission}")
            
        except Exception as e:
            logger.error(f"Error adding permission: {e}")
    
    @staticmethod
    def list_permissions(manifest_path: str):
        """List semua permissions dalam manifest"""
        try:
            tree = ET.parse(manifest_path)
            root = tree.getroot()
            
            ns = {'android': 'http://schemas.android.com/apk/res/android'}
            permissions = []
            
            for perm in root.findall('uses-permission', ns):
                perm_name = perm.get('{http://schemas.android.com/apk/res/android}name')
                permissions.append(perm_name)
            
            logger.info(f"Found {len(permissions)} permissions")
            for perm in sorted(permissions):
                logger.info(f"  - {perm}")
            
            return permissions
            
        except Exception as e:
            logger.error(f"Error listing permissions: {e}")
            return []


# ============================================================================
# RESOURCE MODIFICATIONS
# ============================================================================

class ResourceModifier:
    """
    Modifikasi resource file (drawable, layout, etc)
    """
    
    @staticmethod
    def list_resources(decompiled_dir: str):
        """List semua resource directories dan files"""
        res_dir = Path(decompiled_dir) / 'res'
        
        if not res_dir.exists():
            logger.error(f"res folder not found: {res_dir}")
            return {}
        
        resources = {}
        
        for category_dir in res_dir.iterdir():
            if category_dir.is_dir():
                files = list(category_dir.glob('*'))
                resources[category_dir.name] = files
        
        logger.info(f"Resource categories found:")
        for category, files in resources.items():
            logger.info(f"  {category}: {len(files)} files")
        
        return resources
    
    @staticmethod
    def remove_analytics(decompiled_dir: str):
        """
        Remove common analytics libraries
        Clean up telemetry/tracking
        """
        logger.info("Scanning for analytics libraries...")
        
        smali_dir = Path(decompiled_dir) / 'smali'
        if not smali_dir.exists():
            logger.warning("smali folder not found")
            return
        
        # Common analytics library patterns
        analytics_patterns = [
            'google/analytics',
            'com/firebase',
            'com/mixpanel',
            'com/amplitude',
            'com/segment'
        ]
        
        found = []
        for pattern in analytics_patterns:
            matches = list(smali_dir.rglob(f'**/{pattern}/**/*.smali'))
            if matches:
                found.append((pattern, len(matches)))
        
        if found:
            logger.info("Analytics libraries detected:")
            for pattern, count in found:
                logger.info(f"  {pattern}: {count} files")
        else:
            logger.info("No known analytics libraries detected")


# ============================================================================
# BUILD PROPERTY MODIFICATIONS
# ============================================================================

class BuildPropertiesModifier:
    """
    Modifikasi build.prop untuk custom device properties
    """
    
    @staticmethod
    def list_build_properties(decompiled_dir: str):
        """Lihat build properties"""
        prop_file = Path(decompiled_dir) / 'resources.arsc'
        
        logger.info("Build properties are usually encoded in resources.arsc")
        logger.info("For modification, use apktool --debug flag")


# ============================================================================
# CONFIGURATION TEMPLATES
# ============================================================================

class ConfigTemplates:
    """Predefined configurations untuk common scenarios"""
    
    @staticmethod
    def get_aggressive_config():
        """
        Aggressive config: Disable ALL certificate validation
        WARNING: Use only for testing on local network
        """
        return {
            'cleartext_traffic': True,
            'trust_user_ca': True,
            'trust_system_ca': True,
            'disable_hostname_verification': True,
            'debug_mode': True
        }
    
    @staticmethod
    def get_balanced_config():
        """
        Balanced: Good security while allowing intercept
        RECOMMENDED for most use cases
        """
        return {
            'cleartext_traffic': True,
            'trust_user_ca': True,
            'trust_system_ca': True,
            'disable_hostname_verification': False,
            'debug_mode': False
        }
    
    @staticmethod
    def get_safe_config():
        """
        Safe: Minimal changes, only user CA
        Use for production-like testing
        """
        return {
            'cleartext_traffic': False,
            'trust_user_ca': True,
            'trust_system_ca': True,
            'disable_hostname_verification': False,
            'debug_mode': False
        }


# ============================================================================
# CUSTOM NETWORK CONFIG GENERATOR
# ============================================================================

class NetworkConfigGenerator:
    """Generate custom network_security_config.xml dengan berbagai options"""
    
    @staticmethod
    def generate_aggressive() -> str:
        """Config paling permissive"""
        return """<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">.</domain>
        <trust-anchors>
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
        <pin-set>
            <!-- No pinning - allow all certs -->
        </pin-set>
    </domain-config>
</network-security-config>
"""
    
    @staticmethod
    def generate_domain_specific(domain: str, allow_cleartext: bool = True) -> str:
        """Config untuk domain tertentu"""
        cleartext_attr = 'cleartextTrafficPermitted="true"' if allow_cleartext else ''
        
        return f"""<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config {cleartext_attr}>
        <domain includeSubdomains="true">{domain}</domain>
        <trust-anchors>
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
    
    <domain-config>
        <domain includeSubdomains="true">.</domain>
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
</network-security-config>
"""
    
    @staticmethod
    def generate_multiple_domains(domains: list) -> str:
        """Config untuk multiple domains"""
        domain_configs = ""
        
        for domain in domains:
            domain_configs += f"""
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">{domain}</domain>
        <trust-anchors>
            <certificates src="user" />
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
"""
        
        return f"""<?xml version="1.0" encoding="utf-8"?>
<network-security-config>{domain_configs}
    
    <domain-config>
        <domain includeSubdomains="true">.</domain>
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
</network-security-config>
"""


# ============================================================================
# USAGE EXAMPLES (main function)
# ============================================================================

if __name__ == '__main__':
    print("""
APK ADVANCED MODIFICATIONS - Helper Module
=============================================

This is a helper module for advanced customizations.
Import dan gunakan dari apk_patcher workflow Anda.

Examples:

1. Modify strings:
   from config_helper import StringsXMLModifier
   StringsXMLModifier.modify_strings('decompiled_app', {
       'api_url': 'https://debug.example.com',
       'debug_mode': 'true'
   })

2. List permissions:
   from config_helper import PermissionModifier
   PermissionModifier.list_permissions('AndroidManifest.xml')

3. Custom network config:
   from config_helper import NetworkConfigGenerator
   config = NetworkConfigGenerator.generate_domain_specific('api.example.com')

4. Detect analytics:
   from config_helper import ResourceModifier
   ResourceModifier.remove_analytics('decompiled_app')

See examples_usage.py untuk more examples!
    """)
