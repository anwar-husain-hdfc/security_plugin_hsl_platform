
import 'package:security_plugin_hsl_platform/security_check_result.dart';

import 'security_plugin_hsl_platform_platform_interface.dart';

class SecurityPluginHslPlatform {
  Future<String?> getPlatformVersion() {
    return SecurityPluginHslPlatformPlatform.instance.getPlatformVersion();
  }
  Future<SecurityCheckResult> init() {
    return SecurityPluginHslPlatformPlatform.instance.init();
  }
}
