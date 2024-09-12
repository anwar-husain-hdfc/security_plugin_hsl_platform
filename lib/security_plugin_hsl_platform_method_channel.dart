import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_security_checker/flutter_security_checker.dart';
import 'package:security_plugin_hsl_platform/security_check_result.dart';
import 'package:security_plugin_hsl_platform/security_utils/security_utils.dart';
import 'package:security_plugin_hsl_platform/util/encrypt_pref.dart';

import 'device_security_status.dart';
import 'models/hsl_security.dart';
import 'security_plugin_hsl_platform_platform_interface.dart';

const String MEETS_DEVICE_INTEGRITY = "MEETS_DEVICE_INTEGRITY";
const String MEETS_BASIC_INTEGRITY = "MEETS_BASIC_INTEGRITY";
const String MEETS_STRONG_INTEGRITY = "MEETS_STRONG_INTEGRITY";

/// An implementation of [SecurityPluginHslPlatformPlatform] that uses method channels.
class MethodChannelSecurityPluginHslPlatform
    extends SecurityPluginHslPlatformPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('security_plugin_hsl_platform');
  List<String> secondaryMessage = [];
  bool isTesting = false;
  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<SecurityCheckResult> init(HslSecurity hslSecurity) async {
    bool isTampered = false;
    bool sslVerified = true;
    isTesting = hslSecurity.isTesting;
    try {
      final results = await Future.wait([
        _checkNativeRootDetection(hslSecurity),
        _checkRoot(hslSecurity),
        _checkAppIntegrity(hslSecurity),
        _checkiOSSpecificSecurity(hslSecurity)
      ]);
      // if (Platform.isAndroid) _checkAndroidSpecificSecurity()
      final nativeRootCheck = results[0];
      _logDebug("[_checkNativeRootDetection] - nativeRootCheck - $nativeRootCheck");
      final checkRootFlutterSc = results[1];
      _logDebug("[_checkRoot] - checkRootFlutterSc - $checkRootFlutterSc");
      final isAppVerified = results[2];
      _logDebug("[_checkAppIntegrity] - isAppVerified - $isAppVerified");
      bool jailbroken =  results[3];
      _logDebug("[_checkiOSSpecificSecurity] - jailbroken - $jailbroken");

      final bool rooted = checkRootFlutterSc || nativeRootCheck || jailbroken;

/*    final bool nativeRootCheck = await _checkNativeRootDetection();
    _logDebug("nativeRootCheck - $nativeRootCheck");
    final bool checkRootFlutterSc = await _checkRoot();
    _logDebug("checkRootFlutterSc - $checkRootFlutterSc");
    final bool rooted = checkRootFlutterSc || nativeRootCheck;
    final bool isAppVerified = await _checkAppIntegrity();*/

    if (rooted) {
      _logDebug("device is rooted");
    }

    if (!isAppVerified && !rooted) {
      _logDebug("Device status: Tampered Unverified and Not rooted");
      isTampered = true;
    }

    if (!isAppVerified && rooted) {
      _logDebug("Device status: Unverified and Rooted");
      isTampered = true;
    }

    if (Platform.isAndroid) {
      // For now, setting SSL verification to true as going with the existing implementation.
      // This is a placeholder and should be replaced with actual security checks.
      sslVerified = true;
      // Uncomment the following line once the _checkAndroidSpecificSecurity method is implemented in IR and need to use it
      // sslVerified = await _checkAndroidSpecificSecurity();
    }

    if (isTampered) {
      return SecurityCheckResult(
          DeviceSecurityStatus.tampered, secondaryMessage);
    } else if (rooted) {
      return SecurityCheckResult(DeviceSecurityStatus.rooted, secondaryMessage);
    } else if (!isAppVerified) {
      return SecurityCheckResult(
          DeviceSecurityStatus.unverified, secondaryMessage);
    } else if (!sslVerified) {
      return SecurityCheckResult(
          DeviceSecurityStatus.sslUnverified, secondaryMessage);
    } else {
      return SecurityCheckResult(DeviceSecurityStatus.secure, secondaryMessage);
    }
    } catch (e) {
      _logError('Error during security check initialization', e);
      return SecurityCheckResult(
          DeviceSecurityStatus.secure, ['Error during initialization']);
    }
  }

  Future<bool> _checkAndroidSpecificSecurity() async {
    await SecurityUtils.loadValidFingerprints();
    final bool isValidSSLCert = await SecurityUtils.checkValidSSLCertificate();
    if (!isValidSSLCert) {
      _logDebug("isValidSSLCert = false");
      return false;
    } else {
      _logDebug("isValidSSLCert = true");
      return true;
    }
  }

  Future<bool> _checkRoot(HslSecurity hslSecurity) async {
    if (hslSecurity.rootCheck == false) return false;
    if (kDebugMode && !isTesting) {
      return false;
    }
    return FlutterSecurityChecker.isRooted;
  }

  Future<bool> _checkNativeRootDetection(HslSecurity hslSecurity) async {
    if (Platform.isAndroid && hslSecurity.rootCheck == false) return false;
    if (Platform.isIOS && hslSecurity.jailbreakCheck == false) return false;
    if (kDebugMode && !isTesting) {
      return false;
    }

    try {
      // final bool isRooted = await methodChannel.invokeMethod<bool>('root_detection') ?? false;
      final bool isRooted;
      List<dynamic>? playIntegrityRaw;
      bool isPlayIntegrityPassed = true; // Default to true or handle as needed for non-Android
      final results = await Future.wait([
        methodChannel.invokeMethod<bool>('root_detection'),
        if (Platform.isAndroid) methodChannel.invokeMethod<List<dynamic>>('play_integrity'),
      ]);
      // Extract results
      isRooted = results[0] as bool? ?? false;
      _logDebug("_checkNativeRootDetection isRooted- $isRooted");
      if (Platform.isAndroid) {
        playIntegrityRaw = results[1] as List<dynamic>?;
        // Fetch Play Integrity data with null safety
        // final List<dynamic>? playIntegrityRaw =
        //     await methodChannel.invokeMethod<List<dynamic>>('play_integrity');
        // Handle potential null values explicitly
        if (playIntegrityRaw != null) {
          final List<String> playIntegrity =
              playIntegrityRaw.map((e) => e.toString()).toList();
          isPlayIntegrityPassed = _isPlayIntegrity(playIntegrity);

          // Check if Play Integrity check has passed
          if (!isPlayIntegrityPassed) {
            secondaryMessage.add(
                "Warning: Play Integrity Check Failed - The application did not pass the Play Integrity check. This may indicate a compromised or unverified environment.");
          }

          _logDebug("PlayIntegrity List - $playIntegrity");
          _logDebug("isPlayIntegrityPassed - $isPlayIntegrityPassed");
        } else {
          _logDebug("PlayIntegrity check returned null.");
        }
      } else {
        _logDebug("Skipping play integrity check on non-Android platform.");
      }
      return isRooted || !isPlayIntegrityPassed;
    } catch (e, stackTrace) {
      _logError('Error checking native root detection', e, stackTrace);
      return false;
    }
  }

  bool _isPlayIntegrity(List<String> playIntegrity) {
    return playIntegrity.contains(MEETS_BASIC_INTEGRITY) ||
        playIntegrity.contains(MEETS_DEVICE_INTEGRITY);
/*        &&
        playIntegrity.contains(MEETS_DEVICE_INTEGRITY) &&
        playIntegrity.contains(MEETS_STRONG_INTEGRITY);*/
  }

  Future<bool> _checkAppIntegrity(HslSecurity hslSecurity) async {
    if (hslSecurity.appIntegrity == false) return true;
    if (kDebugMode && !isTesting) {
      return true;
    }

    try {
      final bool isRealDevice = hslSecurity.emulatorCheck ? await _isRealDevice() : true;
      final bool hasCorrectlyInstalled =
          Platform.isAndroid ? await _hasCorrectlyInstalled() : true;
      final bool hasFridaOrMagiskDetected = hslSecurity.fridaMagisk
          ? Platform.isAndroid ? await _fridaOrMagiskDetected() : false
          : false;

      // Check if the device is real
      if (!isRealDevice) {
        secondaryMessage.add(
            "Warning: Emulator Detected! The application may not function correctly on emulated devices.");
      }

      // Check if the app is correctly installed
      if (!hasCorrectlyInstalled) {
        secondaryMessage.add(
            "Alert: App Integrity Compromised - The application is not correctly installed. Please reinstall the app.");
      }

      // Check for the presence of dangerous apps like Frida or Magisk
      if (hasFridaOrMagiskDetected) {
        secondaryMessage.add(
            "Critical: App Integrity Compromised - Frida, Magisk, or other potentially dangerous applications detected. Please ensure the device is secure.");
      }

      return isRealDevice && hasCorrectlyInstalled && !hasFridaOrMagiskDetected;
    } catch (e) {
      _logError('Error checking app integrity', e);
      return false;
    }
  }

  Future<bool> _isRealDevice() async {
    try {
      if (Platform.isAndroid) {
        final bool isEmulator =
            await methodChannel.invokeMethod<bool>('emulator_detection') ??
                false;
        if (isEmulator) {
          final HslSecurityEncryptedPref? preferences =
              await HslSecurityEncryptedPref.getInstance();
          await preferences?.setBool("emulator_detected", isEmulator);
          _logDebug("EmulatorCheck: emulatorDetected $isEmulator");
          return false;
        }

        final HslSecurityEncryptedPref? preferences =
            await HslSecurityEncryptedPref.getInstance();
        final bool emulatorDetected =
            preferences?.getBool("emulator_detected") ?? false;
        if (emulatorDetected) {
          _logDebug("EmulatorCheck: emulatorDetected pref");
          return false;
        }
      }
      return await FlutterSecurityChecker.isRealDevice;
    } catch (e) {
      _logError('Error checking if device is real', e);
      return false;
    }
  }

  Future<bool> _hasCorrectlyInstalled() async {
    try {
      return FlutterSecurityChecker.hasCorrectlyInstalled;
    } catch (e) {
      _logError('Error checking if app is correctly installed', e);
      return false;
    }
  }

  Future<bool> _checkiOSSpecificSecurity(HslSecurity hslSecurity) async {
    try {
      if (hslSecurity.jailbreakCheck == false) return false;
      bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      bool developerMode = await FlutterJailbreakDetection.developerMode; // android only.
      _logDebug("FlutterJailbreakDetection: jailbroken $jailbroken");
      _logDebug("FlutterJailbreakDetection: developerMode $developerMode");
      return jailbroken;
    } catch (e) {
      _logError('Error checking if app is correctly installed', e);
      return false;
    }
  }

  Future<bool> _fridaOrMagiskDetected() async {
    try {
      final bool isAppIntegrity =
          await methodChannel.invokeMethod<bool>('app_integrity') ?? false;
      if (isAppIntegrity) {
        _logDebug("app_integrity: fridaOrMagiskDetected true");
      }
      return isAppIntegrity;
    } catch (e) {
      _logError('Error detecting Frida or Magisk', e);
      return false;
    }
  }

  void _logError(String message, Object e, [StackTrace? stackTrace]) {
    if (kDebugMode || isTesting) {
      debugPrint('HSL_SECURITY: $message: $e');
    }
  }

  void _logDebug(String message) {
    if (kDebugMode || isTesting) {
      debugPrint('HSL_SECURITY: $message');
    }
  }
}
