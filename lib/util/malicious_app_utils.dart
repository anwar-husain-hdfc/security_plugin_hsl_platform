import 'package:device_apps/device_apps.dart';

class MaliciousAppUtils {
  static List<String> loggerApps = [
    'com.gpow.keylogger',
    'com.example.keylogger',
    // Add more known logger app package names here
  ];

  static List<String> maliciousApps = [
    'com.anydesk.anydeskandroid',
    'com.teamviewer.teamviewer.market.mobile',
    'com.topjohnwu.magisk',
    'eu.chainfire.supersu',
    'com.kingroot.kinguser',
    'com.joeykrim.rootcheck',
    'com.mgyun.shua.su',
    'com.android.vending.billing.InAppBillingService.COIN',
    'com.chelpus.lackypatch',
    'org.sbtools.gamehack',
    'com.xmodgame',
    'com.koushikdutta.rommanager',
    'com.tenkiv.rootvalidator',
    'com.droidsheep.droidsheep',
    'com.droidjack.droidjack',
    'com.security.emanations',
    'com.wifikill',
    'kali.nethunter',
  ];

  static Future<String> checkForMaliciousApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
    );

    for (var app in apps) {
      if (loggerApps.contains(app.packageName)) {
        return app.appName;
      }
    }

    for (var app in apps) {
      if (maliciousApps.contains(app.packageName)) {
        return app.appName;
      }
    }
    return '';
  }
}
