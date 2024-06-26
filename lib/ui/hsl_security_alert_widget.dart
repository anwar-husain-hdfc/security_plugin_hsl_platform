import 'dart:io';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:security_plugin_hsl_platform/ui/hsl_security_theme_global.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';

import '../device_security_status.dart';
import '../security_check_result.dart';

class HslSecurityAlertWidget extends StatelessWidget {
  static const TAG = 'HslSecurityAlertWidget';
  final SecurityCheckResult? securityCheckResult;
  final HslSecurityThemeGlobal theme;
  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  final String packageName;
  HslSecurityAlertWidget(this.packageName, {this.securityCheckResult, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      isPartiallyAnimated: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FeatherIcons.shieldOff,
                    size: 100,
                    color: theme.APP_COLOR,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    getSecurityMessage(),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    getSecuritySecondaryMessage(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Spacer(),
              if (isTampered())
                RoundedLoadingButton(
                  borderRadius: 12,
                  width: MediaQuery.of(context).size.width,
                  color: theme.APP_COLOR,
                  controller: _btnController,
                  child: Text(
                      'Download from ${Platform.isAndroid ? 'Play' : Platform.isIOS ? 'App' : 'Trused'} Store',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: theme.WHITE_COLOR)),
                  onPressed: () async {
                    await launchUrlString(
                      Platform.isAndroid
                          ? 'https://play.google.com/store/apps/details?id=$packageName'
                          : Platform.isIOS
                          ? 'https://apps.apple.com/in/app/sky-hdfc/id6447300262'
                          : 'https://hdfcsky.onelink.me/GjMn/ewet8kk7',
                      mode: LaunchMode.externalApplication,
                    );
                    _btnController.reset();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool isTampered() => securityCheckResult?.status==DeviceSecurityStatus.tampered || securityCheckResult?.status==DeviceSecurityStatus.unverified;

  String getSecurityMessage() {
    if (securityCheckResult == null) {
      return 'Security check result is unavailable.';
    }

    String securityMessage;

    switch (securityCheckResult?.status) {
      case DeviceSecurityStatus.tampered:
        securityMessage =
            'Unauthorized modifications or alterations to the app are strictly prohibited to ensure security and maintain the app\'s integrity.';
        break;
      case DeviceSecurityStatus.rooted:
        securityMessage =
            'It seems like your device does not follow the security policies of HDFC securities. Please disable ${Platform.isIOS ? 'jail-breaking' : 'rooting'} and try again.';
        break;
      case DeviceSecurityStatus.unverified:
        securityMessage =
            'The application is not verified. Please ensure it is downloaded from a trusted source to maintain security and app integrity.';
        break;
      case DeviceSecurityStatus.sslUnverified:
        securityMessage =
            'The SSL certificate could not be verified. This may indicate a man-in-the-middle attack, compromising security.';
        break;
      case DeviceSecurityStatus.secure:
        securityMessage = 'Your device meets the security policies of HDFC securities.';
        break;
      default:
        securityMessage = 'Unknown security status.';
        break;
    }

    return securityMessage;
  }

  String getSecuritySecondaryMessage() {
    String securityMessage = '';
    if (securityCheckResult?.messages.isNotEmpty == true) {
      String? additionalMessages = securityCheckResult?.messages.join('\n\n');
      securityMessage =
      '$securityMessage\n\nAdditional Information:\n\n$additionalMessages';
    }
    return securityMessage;
  }
}

class GradientScaffold extends StatelessWidget {
  final bool isPartiallyAnimated;
  final Widget body;

  GradientScaffold({required this.isPartiallyAnimated, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
    );
  }
}

