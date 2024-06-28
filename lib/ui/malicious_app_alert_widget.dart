import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:security_plugin_hsl_platform/ui/hsl_security_theme_global.dart';

class MaliciousAppAlertWidget extends StatelessWidget {
  final String appName;
  final VoidCallback onOk;
  final bool isKeylogger;

  MaliciousAppAlertWidget({
    required this.appName,
    required this.isKeylogger,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    final theme = HslSecurityThemeGlobal(APP_COLOR: Colors.blueAccent, WHITE_COLOR: Colors.white);

    return AlertDialog(
      title: Icon(
        FeatherIcons.shieldOff,
        size: 60,
        color: theme.APP_COLOR,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Security Alert',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'The application "$appName" has been identified as potentially malicious. It is strongly recommended to uninstall this application to protect your device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Understood', style: TextStyle(color: theme.APP_COLOR)),
          onPressed: () => onOk(),
        ),
      ],
    );
  }
}

