import 'dart:io';

import 'package:flutter/material.dart';
import 'package:secure_application/secure_application.dart';
import 'dart:async'; // For StreamSubscription


class SecureApplicationWrapper extends StatefulWidget {
  final Widget child;
  final bool isSecurityEnabled;
  const SecureApplicationWrapper({super.key, required this.isSecurityEnabled, required this.child});

  @override
  State<StatefulWidget> createState() => _SecureApplicationWrapperState();
}

class _SecureApplicationWrapperState extends State<SecureApplicationWrapper> {
  StreamSubscription<bool>? subLock;
  List<String> history = [];
  static const int nativeRemoveDelay = 300;

  @override
  void initState() {
    super.initState();
    // Initialize the subscription in initState
    if(widget.isSecurityEnabled && Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final secureProvider = SecureApplicationProvider.of(
            context, listen: false);
        if (secureProvider != null) {
          subLock = secureProvider.lockEvents.listen((s) {
            setState(() {
              history.add('${DateTime.now().toIso8601String()} - ${s
                  ? 'locked'
                  : 'unlocked'}');
            });
          });
        } else {
          debugPrint('SecureApplicationProvider not found');
        }
      });
    }
  }

  @override
  void dispose() {
    // Ensure the subscription is canceled to avoid memory leaks
    subLock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSecurityEnabled == false || Platform.isAndroid) {
      return widget.child;
    } else {
      return SecureApplication(
      nativeRemoveDelay: nativeRemoveDelay,
      onNeedUnlock: (secure) async {
        debugPrint('Need unlock. Use biometric to confirm and then secure.unlock() or use the lockedBuilder.');
        return null;
      },
      child: Builder(builder: (context) {
        final valueNotifier = SecureApplicationProvider.of(context);
        if (valueNotifier != null) {
          valueNotifier.secure();
        } else {
          debugPrint('Unable to find secure application context');
        }
        return widget.child;
      }),
    );
    }
  }
}



