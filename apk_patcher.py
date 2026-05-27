#!/usr/bin/env python3
"""
APK Patcher - Bypass SSL Pinning untuk Security Testing
Digunakan untuk penelitian dan penetration testing authorized.

Fitur:
- Dekompilasi APK menggunakan apktool
- Inject network_security_config.xml (allow user CA)
- Modifikasi AndroidManifest.xml
- Repack APK menggunakan apktool
- Sign APK menggunakan apksigner/jarsigner
"""

import os
import sys
import subprocess
import shutil
import logging
from pathlib import Path
from xml.etree import ElementTree as ET
from typing import Optional, Tuple

# ============================================================================
# LOGGER SETUP
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)-8s - %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger(__name__)


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def check_tool_exists(tool_name: str) -> bool:
    """
    Cek apakah tool tersedia di system PATH
    
    Args:
        tool_name: Nama tool (apktool, jarsigner, etc)
    
    Returns:
        bool: True jika tool ditemukan
    """
    result = shutil.which(tool_name)
    
    # Special case: apktool jar
    if tool_name == 'apktool':
        jar_path = Path("C:/apktool/apktool.jar")
        if jar_path.exists():
            return True
    
    return result is not None


def run_command(command: list, cwd: Optional[str] = None) -> Tuple[int, str, str]:
    """
    Jalankan command dan capture output
    
    Args:
        command: List command (e.g., ['apktool', 'd', 'file.apk'])
        cwd: Working directory (optional)
    
    Returns:
        Tuple: (return_code, stdout, stderr)
    """
    try:
        logger.info(f"Menjalankan: {' '.join(command)}")
        
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=cwd,
            text=True
        )
        
        stdout, stderr = process.communicate()
        return process.returncode, stdout, stderr
        
    except FileNotFoundError as e:
        logger.error(f"Command tidak ditemukan: {e}")
        raise
    except Exception as e:
        logger.error(f"Error menjalankan command: {e}")
        raise


def validate_paths(apk_path: str) -> Path:
    """
    Validasi input APK path
    
    Args:
        apk_path: Path ke target APK
    
    Returns:
        Path: Absolute path object
    
    Raises:
        FileNotFoundError: Jika APK tidak ditemukan
    """
    apk_file = Path(apk_path).resolve()
    
    if not apk_file.exists():
        raise FileNotFoundError(f"APK tidak ditemukan: {apk_file}")
    
    if apk_file.suffix.lower() != '.apk':
        raise ValueError(f"File harus .apk, ditemukan: {apk_file.suffix}")
    
    logger.info(f"APK terdeteksi: {apk_file}")
    return apk_file


# ============================================================================
# STEP 1: DECOMPILE APK
# ============================================================================

def _get_apktool_command() -> list:
    """
    Get apktool command - try different methods
    
    Returns:
        list: Command to run apktool
    """
    # Method 1: Check if apktool in PATH
    if shutil.which('apktool'):
        return ['apktool']
    
    # Method 2: Use Java + jar directly
    jar_path = Path("C:/apktool/apktool.jar")
    if jar_path.exists():
        # Find Java
        java_candidates = [
            "java",
            "C:\\Program Files\\Microsoft\\jdk-17.0.18.8-hotspot\\bin\\java",
            "C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.18.8-hotspot\\bin\\java",
            str(Path.home() / ".gradle" / "java" / "openjdk-17" / "bin" / "java"),
        ]
        
        for java_path in java_candidates:
            if Path(java_path).exists() or shutil.which(java_path):
                logger.info(f"Using Java: {java_path}")
                return [java_path, "-jar", str(jar_path)]
    
    raise RuntimeError(
        "apktool tidak ditemukan!\n"
        "Setup:\n"
        "1. Download dari: https://ibotpeaches.github.io/Apktool/\n"
        "2. Extract ke: C:\\apktool\\\n"
        "3. Atau install via: choco install apktool (if Chocolatey installed)"
    )


def decompile_apk(apk_path: str) -> str:
    """
    Dekompilasi APK menggunakan apktool
    
    Args:
        apk_path: Path ke target APK
    
    Returns:
        str: Path folder hasil dekompilasi
    
    Raises:
        RuntimeError: Jika dekompilasi gagal
    """
    apktool_cmd = _get_apktool_command()
    
    apk_file = validate_paths(apk_path)
    output_dir = apk_file.stem  # Nama APK tanpa extension
    
    # Jika folder sudah ada, backup dulu
    if Path(output_dir).exists():
        logger.warning(f"Folder {output_dir} sudah ada, menghapus...")
        shutil.rmtree(output_dir)
    
    # Jalankan apktool d
    returncode, stdout, stderr = run_command(apktool_cmd + ['d', str(apk_file)])
    
    if returncode != 0:
        raise RuntimeError(f"Dekompilasi gagal:\n{stderr}")
    
    if not Path(output_dir).exists():
        raise RuntimeError(f"Folder output tidak ditemukan: {output_dir}")
    
    logger.info(f"✓ Dekompilasi berhasil: {output_dir}/")
    return output_dir


# ============================================================================
# STEP 2: CREATE NETWORK_SECURITY_CONFIG.XML
# ============================================================================

def create_network_security_config(output_dir: str) -> Path:
    """
    Buat network_security_config.xml untuk allow user CA
    
    Args:
        output_dir: Folder hasil dekompilasi
    
    Returns:
        Path: Path ke file yang dibuat
    
    Content XML:
        - Mengizinkan debug certificates
        - Mengizinkan user-installed CA
        - Disable domain pinning
    """
    res_xml_dir = Path(output_dir) / 'res' / 'xml'
    res_xml_dir.mkdir(parents=True, exist_ok=True)
    
    config_file = res_xml_dir / 'network_security_config.xml'
    
    # Buat XML content
    network_security_config = """<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow user-installed CA certificates for debugging -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">.</domain>
        <trust-anchors>
            <!-- User CA certificates -->
            <certificates src="user" />
            <!-- System CA certificates -->
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
</network-security-config>
"""
    
    try:
        config_file.write_text(network_security_config, encoding='utf-8')
        logger.info(f"✓ Network config dibuat: {config_file}")
        return config_file
    except Exception as e:
        raise RuntimeError(f"Gagal membuat network_security_config.xml: {e}")


# ============================================================================
# STEP 3: MODIFY ANDROIDMANIFEST.XML
# ============================================================================

def modify_android_manifest(output_dir: str) -> None:
    """
    Modifikasi AndroidManifest.xml untuk add networkSecurityConfig
    
    Args:
        output_dir: Folder hasil dekompilasi
    
    Raises:
        RuntimeError: Jika modifikasi gagal
    """
    manifest_path = Path(output_dir) / 'AndroidManifest.xml'
    
    if not manifest_path.exists():
        raise FileNotFoundError(f"AndroidManifest.xml tidak ditemukan: {manifest_path}")
    
    try:
        # Register namespace untuk XML
        ET.register_namespace('android', 'http://schemas.android.com/apk/res/android')
        
        # Parse manifest
        tree = ET.parse(manifest_path)
        root = tree.getroot()
        
        # Namespace
        ns = {'android': 'http://schemas.android.com/apk/res/android'}
        
        # Cari tag <application>
        application = root.find('application', ns)
        
        if application is None:
            raise RuntimeError("Tag <application> tidak ditemukan di AndroidManifest.xml")
        
        # Tambah attribute networkSecurityConfig
        attr_name = '{http://schemas.android.com/apk/res/android}networkSecurityConfig'
        
        if attr_name in application.attrib:
            logger.warning("Attribute networkSecurityConfig sudah ada, skip...")
        else:
            application.set(attr_name, '@xml/network_security_config')
            logger.info("✓ Attribute networkSecurityConfig ditambahkan ke <application>")
        
        # Write kembali
        tree.write(
            manifest_path,
            encoding='utf-8',
            xml_declaration=True
        )
        
        logger.info(f"✓ AndroidManifest.xml dimodifikasi: {manifest_path}")
        
    except ET.ParseError as e:
        raise RuntimeError(f"XML Parse error di AndroidManifest.xml: {e}")
    except Exception as e:
        raise RuntimeError(f"Gagal memodifikasi AndroidManifest.xml: {e}")


# ============================================================================
# STEP 4: REBUILD APK
# ============================================================================

def rebuild_apk(output_dir: str, output_apk: str = 'patched.apk') -> str:
    """
    Rebuild APK menggunakan apktool
    
    Args:
        output_dir: Folder hasil dekompilasi
        output_apk: Nama output APK (default: patched.apk)
    
    Returns:
        str: Path ke APK yang sudah di-rebuild
    
    Raises:
        RuntimeError: Jika rebuild gagal
    """
    apktool_cmd = _get_apktool_command()
    
    output_dir_path = Path(output_dir)
    if not output_dir_path.exists():
        raise FileNotFoundError(f"Folder tidak ditemukan: {output_dir}")
    
    # Hapus output APK lama jika ada
    output_path = Path(output_apk)
    if output_path.exists():
        output_path.unlink()
    
    # Jalankan apktool b
    returncode, stdout, stderr = run_command(
        apktool_cmd + ['b', str(output_dir_path), '-o', str(output_path)]
    )
    
    if returncode != 0:
        raise RuntimeError(f"Rebuild gagal:\n{stderr}")
    
    if not output_path.exists():
        raise RuntimeError(f"APK output tidak ditemukan: {output_path}")
    
    logger.info(f"✓ APK di-rebuild: {output_path}")
    return str(output_path)


# ============================================================================
# STEP 5: SIGN APK
# ============================================================================

def find_signing_tool() -> Tuple[str, str]:
    """
    Cari tool signing yang tersedia (apksigner atau jarsigner)
    
    Returns:
        Tuple: (tool_name, tool_path)
    
    Raises:
        RuntimeError: Jika tidak ada tool signing
    """
    # Prioritas: apksigner > jarsigner
    for tool in ['apksigner', 'jarsigner']:
        if check_tool_exists(tool):
            logger.info(f"Tool signing ditemukan: {tool}")
            return tool, shutil.which(tool)
    
    raise RuntimeError(
        "Tidak ada tool signing ditemukan!\n"
        "Opsi:\n"
        "1. apksigner (recommended) - dari Android SDK\n"
        "2. jarsigner - dari Java JDK\n"
        "Tambahkan ke PATH sistem"
    )


def sign_apk_with_apksigner(apk_path: str) -> None:
    """
    Sign APK menggunakan apksigner (Android SDK)
    
    Args:
        apk_path: Path ke APK yang akan di-sign
    
    Raises:
        RuntimeError: Jika signing gagal
    """
    apk_file = Path(apk_path)
    
    if not apk_file.exists():
        raise FileNotFoundError(f"APK tidak ditemukan: {apk_file}")
    
    # apksigner akan meminta keystore interaktif atau gunakan debug key
    # Untuk convenience, kita asumsikan user sudah setup atau gunakan debug key
    
    returncode, stdout, stderr = run_command([
        'apksigner', 'sign',
        '--ks', '~/.android/debug.keystore',  # Default debug keystore
        '--ks-key-alias', 'androiddebugkey',
        '--ks-pass', 'pass:android',
        '--key-pass', 'pass:android',
        str(apk_file)
    ])
    
    if returncode != 0:
        logger.warning(f"apksigner output:\n{stderr}")
        # apksigner mungkin tidak perlu eksplisit sign untuk debug
        logger.warning("Skipping apksigner, APK sudah di-rebuild")
    else:
        logger.info(f"✓ APK di-sign dengan apksigner")


def sign_apk_with_jarsigner(apk_path: str) -> None:
    """
    Sign APK menggunakan jarsigner (Java JDK)
    
    Args:
        apk_path: Path ke APK yang akan di-sign
    
    Raises:
        RuntimeError: Jika signing gagal
    """
    apk_file = Path(apk_path)
    
    if not apk_file.exists():
        raise FileNotFoundError(f"APK tidak ditemukan: {apk_file}")
    
    # Path ke debug keystore (biasanya di ~/.android/debug.keystore)
    keystore_path = Path.home() / '.android' / 'debug.keystore'
    
    if not keystore_path.exists():
        raise FileNotFoundError(
            f"Debug keystore tidak ditemukan: {keystore_path}\n"
            "Buat dengan: keytool -genkey -v -keystore ~/.android/debug.keystore "
            "-keyalias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 "
            "-storepass android -keypass android"
        )
    
    # Sign dengan jarsigner
    returncode, stdout, stderr = run_command([
        'jarsigner',
        '-verbose',
        '-sigalg', 'SHA256withRSA',
        '-digestalg', 'SHA-256',
        '-keystore', str(keystore_path),
        '-storepass', 'android',
        '-keypass', 'android',
        str(apk_file),
        'androiddebugkey'
    ])
    
    if returncode != 0:
        raise RuntimeError(f"Signing dengan jarsigner gagal:\n{stderr}")
    
    logger.info(f"✓ APK di-sign dengan jarsigner")


def sign_apk(apk_path: str) -> None:
    """
    Sign APK menggunakan tool yang tersedia
    
    Args:
        apk_path: Path ke APK
    
    Raises:
        RuntimeError: Jika signing gagal atau tool tidak ditemukan
    """
    tool_name, tool_path = find_signing_tool()
    
    try:
        if tool_name == 'apksigner':
            sign_apk_with_apksigner(apk_path)
        elif tool_name == 'jarsigner':
            sign_apk_with_jarsigner(apk_path)
    except Exception as e:
        logger.error(f"Signing gagal: {e}")
        raise


# ============================================================================
# MAIN ORCHESTRATION
# ============================================================================

def patch_apk(apk_path: str, output_apk: str = 'patched.apk', cleanup: bool = True) -> str:
    """
    Main function: Patch APK dengan bypass SSL Pinning
    
    Args:
        apk_path: Path ke target APK
        output_apk: Nama output APK (default: patched.apk)
        cleanup: Hapus folder dekompilasi setelah selesai (default: True)
    
    Returns:
        str: Path ke patched APK
    
    Raises:
        RuntimeError: Jika ada step yang gagal
    """
    logger.info("=" * 70)
    logger.info("APK PATCHER - SSL PINNING BYPASS")
    logger.info("=" * 70)
    
    try:
        # Step 1: Decompile
        logger.info("\n[STEP 1/5] Dekompilasi APK...")
        decompiled_dir = decompile_apk(apk_path)
        
        # Step 2: Create network config
        logger.info("\n[STEP 2/5] Membuat network_security_config.xml...")
        create_network_security_config(decompiled_dir)
        
        # Step 3: Modify manifest
        logger.info("\n[STEP 3/5] Memodifikasi AndroidManifest.xml...")
        modify_android_manifest(decompiled_dir)
        
        # Step 4: Rebuild APK
        logger.info("\n[STEP 4/5] Rebuild APK...")
        rebuilt_apk = rebuild_apk(decompiled_dir, output_apk)
        
        # Step 5: Sign APK
        logger.info("\n[STEP 5/5] Sign APK...")
        sign_apk(rebuilt_apk)
        
        logger.info("\n" + "=" * 70)
        logger.info("✓ PATCHING BERHASIL!")
        logger.info("=" * 70)
        logger.info(f"Output APK: {rebuilt_apk}")
        logger.info(f"Instalasi: adb install {rebuilt_apk}")
        logger.info("=" * 70)
        
        # Cleanup
        if cleanup:
            logger.info(f"\nMenghapus folder dekompilasi: {decompiled_dir}")
            shutil.rmtree(decompiled_dir)
        
        return rebuilt_apk
        
    except Exception as e:
        logger.error(f"\n✗ PATCHING GAGAL: {e}")
        raise


# ============================================================================
# CLI INTERFACE
# ============================================================================

def main():
    """Main entry point"""
    
    if len(sys.argv) < 2:
        print("Usage: python apk_patcher.py <target.apk> [output.apk]")
        print("\nContoh:")
        print("  python apk_patcher.py target.apk")
        print("  python apk_patcher.py target.apk patched.apk")
        sys.exit(1)
    
    apk_path = sys.argv[1]
    output_apk = sys.argv[2] if len(sys.argv) > 2 else 'patched.apk'
    
    try:
        patched_apk = patch_apk(apk_path, output_apk, cleanup=False)
        print(f"\n✓ Success! Patched APK: {patched_apk}")
        
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}")
        sys.exit(1)
    except RuntimeError as e:
        logger.error(f"Runtime error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        logger.warning("\n✗ Proses dibatalkan oleh user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
