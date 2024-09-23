import 'package:flutter_test/flutter_test.dart';
import 'package:security_plugin_hsl_platform/models/hsl_security.dart';

void main() {
  group('HslSecurity', () {
    test('HslSecurity.fromJson should create an instance from JSON', () {
      final json = {
        'rootCheck': true,
        'playIntegrity': true,
        'appIntegrity': true,
        'jailbreakCheck': true,
        'secureScreen': true,
        'sslPinning': true,
        'emulatorCheck': true,
        'fridaMagisk': true,
        'keyLogger': true,
        'exemptedHosts': ['example.com', 'test.com'],
      };

      final security = HslSecurity.fromJson(json);

      expect(security.rootCheck, true);
      expect(security.playIntegrity, true);
      expect(security.appIntegrity, true);
      expect(security.jailbreakCheck, true);
      expect(security.secureScreen, true);
      expect(security.sslPinning, true);
      expect(security.emulatorCheck, true);
      expect(security.fridaMagisk, true);
      expect(security.keyLogger, true);
      expect(security.exemptedHosts, ['example.com', 'test.com']);
    });

    test('HslSecurity.fromJson should handle missing fields', () {
      final json = {
        'rootCheck': true,
        'exemptedHosts': ['example.com'],
      };

      final security = HslSecurity.fromJson(json);

      expect(security.rootCheck, true);
      expect(security.playIntegrity, false);
      expect(security.appIntegrity, false);
      expect(security.jailbreakCheck, false);
      expect(security.secureScreen, false);
      expect(security.sslPinning, false);
      expect(security.emulatorCheck, false);
      expect(security.fridaMagisk, false);
      expect(security.keyLogger, false);
      expect(security.exemptedHosts, ['example.com']);
    });

    test('HslSecurity.toJson should convert instance to JSON', () {
      final security = HslSecurity(
        rootCheck: true,
        playIntegrity: true,
        appIntegrity: false,
        jailbreakCheck: true,
        secureScreen: false,
        sslPinning: true,
        emulatorCheck: false,
        fridaMagisk: true,
        keyLogger: false,
        playIntegrityHome: true,
        exemptedHosts: ['example.com', 'test.com'],
      );

      final json = security.toJson();

      expect(json['rootCheck'], true);
      expect(json['playIntegrity'], true);
      expect(json['appIntegrity'], false);
      expect(json['jailbreakCheck'], true);
      expect(json['secureScreen'], false);
      expect(json['sslPinning'], true);
      expect(json['emulatorCheck'], false);
      expect(json['fridaMagisk'], true);
      expect(json['keyLogger'], false);
      expect(json['exemptedHosts'], ['example.com', 'test.com']);
    });

    test('HslSecurity.toString should return a formatted string', () {
      final security = HslSecurity(
        rootCheck: false,
        playIntegrity: true,
        appIntegrity: false,
        jailbreakCheck: true,
        secureScreen: false,
        sslPinning: true,
        emulatorCheck: false,
        fridaMagisk: true,
        keyLogger: false,
        playIntegrityHome: true,
        exemptedHosts: ['example.com'],
      );

      final string = security.toString();
      expect(string,
          'HslSecurity(rootCheck: false, playIntegrity: true, appIntegrity: false, '
              'jailbreakCheck: true, secureScreen: false, sslPinning: true, '
              'emulatorCheck: false, fridaMagisk: true, keyLogger: false, '
              'exemptedHosts: example.com)');
    });


    test('HslSecurity.fromJson should handle empty JSON', () {
      final Map<String, dynamic>  json = {};

      final security = HslSecurity.fromJson(json);

      expect(security.rootCheck, false);
      expect(security.playIntegrity, false);
      expect(security.appIntegrity, false);
      expect(security.jailbreakCheck, false);
      expect(security.secureScreen, false);
      expect(security.sslPinning, false);
      expect(security.emulatorCheck, false);
      expect(security.fridaMagisk, false);
      expect(security.keyLogger, false);
      expect(security.exemptedHosts, []);
    });

    test('HslSecurity.fromJson should handle null exemptedHosts', () {
      final json = {
        'rootCheck': true,
        'exemptedHosts': null,
      };

      final security = HslSecurity.fromJson(json);

      expect(security.rootCheck, true);
      expect(security.exemptedHosts, []);
    });

    test('HslSecurity.fromJson should handle invalid exemptedHosts type', () {
      final json = {
        'rootCheck': true,
        'exemptedHosts': 'not a list',
      };

      expect(() => HslSecurity.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('HslSecurity.toJson should handle empty exemptedHosts', () {
      final security = HslSecurity(
        rootCheck: true,
        playIntegrity: false,
        appIntegrity: false,
        jailbreakCheck: false,
        secureScreen: false,
        sslPinning: false,
        emulatorCheck: false,
        fridaMagisk: false,
        keyLogger: false,
        playIntegrityHome: true,
        exemptedHosts: [],
      );

      final json = security.toJson();

      expect(json['exemptedHosts'], []);
    });

    test('HslSecurity.toString should handle empty exemptedHosts', () {
      final security = HslSecurity(
        rootCheck: true,
        playIntegrity: false,
        appIntegrity: false,
        jailbreakCheck: false,
        secureScreen: false,
        sslPinning: false,
        emulatorCheck: false,
        fridaMagisk: false,
        keyLogger: false,
        playIntegrityHome: true,
        exemptedHosts: [],
      );

      final string = security.toString();
      expect(string,
          'HslSecurity(rootCheck: true, playIntegrity: false, appIntegrity: false, '
              'jailbreakCheck: false, secureScreen: false, sslPinning: false, '
              'emulatorCheck: false, fridaMagisk: false, keyLogger: false, '
              'exemptedHosts: )');
    });

    test('HslSecurity.fromJson should handle large number of exemptedHosts', () {
      final json = {
        'rootCheck': true,
        'exemptedHosts': List<String>.generate(1000, (index) => 'host$index.com'),
      };

      final security = HslSecurity.fromJson(json);

      expect(security.exemptedHosts.length, 1000);
      expect(security.exemptedHosts.first, 'host0.com');
      expect(security.exemptedHosts.last, 'host999.com');
    });

    test('HslSecurity.toJson should handle large number of exemptedHosts', () {
      final exemptedHosts = List<String>.generate(1000, (index) => 'host$index.com');
      final security = HslSecurity(
        rootCheck: false,
        playIntegrity: false,
        appIntegrity: false,
        jailbreakCheck: false,
        secureScreen: false,
        sslPinning: false,
        emulatorCheck: false,
        fridaMagisk: false,
        keyLogger: false,
        playIntegrityHome: true,
        exemptedHosts: exemptedHosts,
      );

      final json = security.toJson();

      expect(json['exemptedHosts'].length, 1000);
      expect(json['exemptedHosts'].first, 'host0.com');
      expect(json['exemptedHosts'].last, 'host999.com');
    });
  });
}