import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

import '../util/theme_provider.dart';

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
    final theme = Provider.of<ThemeGlobal>(context);

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
              style: theme.themeData?.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The application "$appName" has been identified as potentially malicious. It is strongly recommended to uninstall this application to protect your device.',
              style: theme.themeData?.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
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

