import 'package:flutter_test/flutter_test.dart';
import 'package:security_plugin_hsl_platform/models/hsl_security.dart';
import 'package:security_plugin_hsl_platform/models/play_integrity_status.dart';
import 'package:security_plugin_hsl_platform/security_check_result.dart';
import 'package:security_plugin_hsl_platform/security_plugin_hsl_platform.dart';
import 'package:security_plugin_hsl_platform/security_plugin_hsl_platform_platform_interface.dart';
import 'package:security_plugin_hsl_platform/security_plugin_hsl_platform_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecurityPluginHslPlatformPlatform
    with MockPlatformInterfaceMixin
    implements SecurityPluginHslPlatformPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<SecurityCheckResult> init(HslSecurity hslSecurity) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<PlayIntegrityStatus?> checkPlayIntegrity(HslSecurity hslSecurity) {
    // TODO: implement checkPlayIntegrity
    throw UnimplementedError();
  }
}

void main() {
  final SecurityPluginHslPlatformPlatform initialPlatform = SecurityPluginHslPlatformPlatform.instance;

  test('$MethodChannelSecurityPluginHslPlatform is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecurityPluginHslPlatform>());
  });

  test('getPlatformVersion', () async {
    SecurityPluginHslPlatform securityPluginHslPlatformPlugin = SecurityPluginHslPlatform();
    MockSecurityPluginHslPlatformPlatform fakePlatform = MockSecurityPluginHslPlatformPlatform();
    SecurityPluginHslPlatformPlatform.instance = fakePlatform;

    expect(await securityPluginHslPlatformPlugin.getPlatformVersion(), '42');
  });
}
