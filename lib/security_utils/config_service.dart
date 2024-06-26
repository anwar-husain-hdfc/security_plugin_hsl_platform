import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// ConfigService to load configuration using MethodChannel
class ConfigService {
  static const MethodChannel _channel = MethodChannel('security_plugin_hsl_platform');

  static Future<Map<String, String>> loadConfig() async {
    try {
      final config = await _channel.invokeMethod<Map>('getConfig');
      return config?.map((key, value) => MapEntry(key, value as String)) ?? {};
    } catch (e) {
      debugPrint('ConfigService: Error loading config: $e');
      return {};
    }
  }
}
