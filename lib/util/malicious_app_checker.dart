import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../ui/malicious_app_alert_widget.dart';
import 'encrypt_pref.dart';
import 'malicious_app_utils.dart';

class MaliciousAppChecker {
  final BuildContext context;

  // Constant for 7 days in milliseconds
  static const int _sevenDaysMs = 7 * 24 * 60 * 60 * 1000;

  // String constants
  static const String _errorTitle = 'Detection Error';
  static const String _errorContent =
      'An error occurred while attempting to detect malicious applications. Please try again later.';
  static const String _okButtonText = 'OK';
  static const String _lastShownTimestampKey = 'lastShownTimestamp';
  // Constructor marked as const to ensure immutability if context does not change
  const MaliciousAppChecker(this.context);

  /// Checks for malicious apps and keyloggers.
  /// Displays a dialog if a malicious app is detected.
  Future<void> checkForMaliciousAppsAndKeyLogger() async {
    if (Platform.isIOS) {
      _logDebug("Skipping Malicious Apps And Key Logger check on non-Android platform.",
          isTesting: true);
      return;
    }
    try {
      final prefs = await HslSecurityEncryptedPref.getInstance();
      final lastShownTimestamp = prefs?.getInt(_lastShownTimestampKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (_shouldShowDialog(lastShownTimestamp, currentTime)) {
        await _showMaliciousAppDialog(prefs, currentTime);
      }
    } catch (e) {
      // Log the error for debugging purposes
      _logDebug('Error checking for malicious apps: $e');
      await _showErrorDialog();
    }
  }

  /// Determines if the dialog should be shown based on the time difference.
  bool _shouldShowDialog(int lastShownTimestamp, int currentTime) {
    return (currentTime - lastShownTimestamp) >= _sevenDaysMs;
  }

  /// Checks for malicious apps and shows a dialog if any are found.
  Future<void> _showMaliciousAppDialog(HslSecurityEncryptedPref? prefs, int currentTime) async {
    try {
      final appName = await MaliciousAppUtils.checkForMaliciousApps();
      if (appName.isNotEmpty) {
        final isKeyloggerDetected = appName.toLowerCase().contains('keylogger');
        await _showMaliciousAppAlertDialog(appName, isKeyloggerDetected, prefs, currentTime);
      }
    } catch (e) {
      // Log the error for debugging purposes
      _logDebug('Error checking for malicious apps: $e');
      await _showErrorDialog();
    }
  }

  /// Shows the alert dialog for a malicious app detection.
  Future<void> _showMaliciousAppAlertDialog(String appName, bool isKeyloggerDetected, HslSecurityEncryptedPref? prefs, int currentTime) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MaliciousAppAlertWidget(
          appName: appName,
          isKeylogger: isKeyloggerDetected,
          onOk: () async {
            // Handle the OK button press
            await _setLastShownTimestamp(prefs, currentTime);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// Displays an error dialog if there is an exception.
  Future<void> _showErrorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_errorTitle),
          content: Text(_errorContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_okButtonText),
            ),
          ],
        );
      },
    );
  }

  /// Sets the last shown timestamp in the shared preferences.
  Future<void> _setLastShownTimestamp(HslSecurityEncryptedPref? prefs, int currentTime) async {
    await prefs?.setInt(_lastShownTimestampKey, currentTime);
  }

  void _logDebug(String message, {bool isTesting = false}) {
    if (kDebugMode || isTesting) {
      print('IR_SECURITY: $message');
    }
  }
}

