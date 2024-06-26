import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_plugin_hsl_platform/security_plugin_hsl_platform_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSecurityPluginHslPlatform platform = MethodChannelSecurityPluginHslPlatform();
  const MethodChannel channel = MethodChannel('security_plugin_hsl_platform');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
