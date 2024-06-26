import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:security_plugin_hsl_platform/device_security_status.dart';
import 'package:security_plugin_hsl_platform/security_check_result.dart';
import 'package:security_plugin_hsl_platform/security_plugin_hsl_platform.dart';
import 'package:security_plugin_hsl_platform/ui/rooted_alert_widget.dart';
import 'package:security_plugin_hsl_platform/ui/secure_application_wrapper.dart';
import 'package:security_plugin_hsl_platform/util/malicious_app_checker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _securityIrPlugin = SecurityPluginHslPlatform();
  SecurityCheckResult securityCheckResult = SecurityCheckResult(
      DeviceSecurityStatus.secure, []);
  bool showDeviceSecurityWidget = false;
  bool isLoading = true;
  var packageName = "";
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    initIRSecurityPlugin();
    initPackageName();
  }

  Future<void> initPackageName() async {
    packageName = await getPackageName();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _securityIrPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initIRSecurityPlugin() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      SecurityCheckResult checkResult = await _securityIrPlugin.init();
      final securityStatus = checkResult.status;
      print('IR_SECURITY: DeviceSecurityStatus ${securityStatus.name}');
      if (securityStatus != DeviceSecurityStatus.secure) {
        setState(() {
          securityCheckResult =
              SecurityCheckResult(securityStatus, checkResult.messages);
          showDeviceSecurityWidget = true;
        });
      }
    } on PlatformException {
      platformVersion = 'Failed to init';
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  StreamSubscription<bool>? subLock;
  List<String> history = [];

  @override
  void dispose() {
    subLock?.cancel();
    super.dispose();
  }

  final theme = ThemeGlobal(
      APP_COLOR: Colors.blueAccent, WHITE_COLOR: Colors.white);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return MaterialApp(
        home: SecureApplicationWrapper(
          child: showDeviceSecurityWidget
              ? RootedAlertWidget(packageName, securityCheckResult: securityCheckResult, theme: theme,)
              : const SecureAppContent(),
        ),
      );
    }
  }
}
class SecureAppContent extends StatelessWidget {
  const SecureAppContent({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MaliciousAppChecker(context).checkForMaliciousAppsAndKeyLogger();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: const Center(
        // child: Text('Running on: $_platformVersion\n'),
          child: Text('Running on: Secure App')
      ),
    );
  }
}
Future<String> getPackageName() async {
  try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName;
  } catch (e) {
    // Handle any errors that might occur during the retrieval
    print('Error retrieving package info: $e');
    return "";
  }
}