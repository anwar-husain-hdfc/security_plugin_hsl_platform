import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:security_plugin_hsl_platform/security_check_result.dart';

import 'models/hsl_security.dart';
import 'security_plugin_hsl_platform_method_channel.dart';

abstract class SecurityPluginHslPlatformPlatform extends PlatformInterface {
  /// Constructs a SecurityPluginHslPlatformPlatform.
  SecurityPluginHslPlatformPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecurityPluginHslPlatformPlatform _instance = MethodChannelSecurityPluginHslPlatform();

  /// The default instance of [SecurityPluginHslPlatformPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecurityPluginHslPlatform].
  static SecurityPluginHslPlatformPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecurityPluginHslPlatformPlatform] when
  /// they register themselves.
  static set instance(SecurityPluginHslPlatformPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<bool?> checkPlayIntegrity(HslSecurity hslSecurity) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<SecurityCheckResult> init(HslSecurity hslSecurity) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
