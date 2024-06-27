import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'config_service.dart';

// SecurityUtils class to manage certificate validation
class SecurityUtils {
  static List<String>? _validFingerprints;

  // Load valid fingerprints asynchronously
  static Future<void> loadValidFingerprints() async {
    _validFingerprints = await getValidFingerprints();
  }

  // Get valid fingerprints synchronously
  static List<String> getValidFingerprintsSync() {
    return _validFingerprints ?? [];
  }

  // Fetch valid fingerprints from config
  static Future<List<String>> getValidFingerprints() async {
    try {
      final config = await ConfigService.loadConfig();
      return [
        if (config['fingerprint1'] != null) config['fingerprint1']!,
        if (config['fingerprint2'] != null) config['fingerprint2']!,
        if (config['fingerprint3'] != null) config['fingerprint3']!,
      ];
    } catch (e) {
      _logDebug('SecurityUtils: Error fetching valid fingerprints: $e');
      return [];
    }
  }

  static bool isCertificateExpired() {
    DateTime? expiryDate = DateTime(2025, 1, 26);
    final currentDate = DateTime.now();
    final certificateExpired =  currentDate.isAfter(expiryDate);
    _logDebug('IsCertificateExpired: $certificateExpired');
    return certificateExpired;
  }

  // Validate certificate fingerprint
  static bool isValidCertificate(String fingerprint) {
    _logDebug('SecurityUtils: fingerprint: $fingerprint');
    final validFingerprints = getValidFingerprintsSync();
    _logDebug('SecurityUtils: fingerprint: $validFingerprints');
    return validFingerprints.contains(fingerprint);
  }

  // Compute SHA-256 fingerprint of the certificate bytes
  static String _getFingerprint(Uint8List certBytes) {
    final digest = sha256.convert(certBytes);
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(':');
  }

  // Function to check the validity of SSL certificate
  static Future<bool> checkValidSSLCertificate() async {
    try {
      if (isCertificateExpired()) return true;
      // final String certPath = ApiConstant.currentEnv == Environment.CUG
      //     ? 'assets/certificate.pem'
      //     : 'assets/sky_uat.pem';
      const String certPath = 'packages/security_plugin_hsl_platform/assets/certificate.pem';
      final sslCert = await rootBundle.load(certPath);
      final certBytes = sslCert.buffer.asUint8List();
      final certFingerprint = SecurityUtils._getFingerprint(certBytes);
      final isValidCertificate = SecurityUtils.isValidCertificate(certFingerprint);
      _logDebug('IsValidCertificate: $isValidCertificate');
      return isValidCertificate;
    } catch (e) {
      _logDebug('Error checking SSL certificate validity: $e');
      return false;
    }
  }
  static const isTesting = true;
  static void _logDebug(String message) {
    if (kDebugMode || isTesting) {
      debugPrint('HSL_SECURITY: $message');
    }
  }
}
