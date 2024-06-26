/*import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../util/theme_provider.dart';*/

/*class ShaFailedAlertWidget extends StatelessWidget {
  static const TAG = 'ShaFailedAlertWidget';
  final bool isTampered;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  ShaFailedAlertWidget({this.isTampered = false});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeGlobal>(context);
    return GradientScaffold(
      isPartiallyAnimated: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
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
                    "Corrupted apk, install it from the play store",
                    style: theme.themeData?.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Spacer(),
              // if (isTampered)
                RoundedLoadingButton(
                  borderRadius: 12,
                  width: MediaQuery.of(context).size.width,
                  color: theme.APP_COLOR,
                  controller: _btnController,
                  child: Text(
                      'Download from ${Platform.isAndroid ? 'Play' : Platform.isIOS ? 'App' : 'Trused'} Store',
                      style: theme.themeData?.textTheme.headlineSmall
                          ?.copyWith(color: theme.WHITE_COLOR)),
                  onPressed: () async {
                    await launchUrlString(
                      Platform.isAndroid
                          ? 'https://play.google.com/store/apps/details?id=${packageInfo?.packageName}'
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
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}*/
