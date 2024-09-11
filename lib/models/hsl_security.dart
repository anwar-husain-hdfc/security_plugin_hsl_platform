import 'dart:convert';

class HslSecurity {
  final bool rootCheck;
  final bool playIntegrity;
  final bool appIntegrity;
  final bool jailbreakCheck;
  final bool secureScreen;
  final bool sslPinning;
  final bool emulatorCheck;
  final bool fridaMagisk;
  final bool keyLogger;
  final List<String> exemptedHosts;

  HslSecurity({
    required this.rootCheck,
    required this.playIntegrity,
    required this.appIntegrity,
    required this.jailbreakCheck,
    required this.secureScreen,
    required this.sslPinning,
    required this.emulatorCheck,
    required this.fridaMagisk,
    required this.keyLogger,
    required this.exemptedHosts,
  });

  // Factory method to create a new instance from a JSON object
  factory HslSecurity.fromJson(Map<String, dynamic> json) {
    return HslSecurity(
      rootCheck: json['rootCheck'] ?? false,
      playIntegrity: json['playIntegrity'] ?? false,
      appIntegrity: json['appIntegrity'] ?? false,
      jailbreakCheck: json['jailbreakCheck'] ?? false,
      secureScreen: json['secureScreen'] ?? false,
      sslPinning: json['sslPinning'] ?? false,
      emulatorCheck: json['emulatorCheck'] ?? false,
      fridaMagisk: json['fridaMagisk'] ?? false,
      keyLogger: json['keyLogger'] ?? false,
      exemptedHosts: List<String>.from(json['exemptedHosts'] ?? []),
    );
  }

  // Method to convert class instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'rootCheck': rootCheck,
      'playIntegrity': playIntegrity,
      'appIntegrity': appIntegrity,
      'jailbreakCheck': jailbreakCheck,
      'secureScreen': secureScreen,
      'sslPinning': sslPinning,
      'emulatorCheck': emulatorCheck,
      'fridaMagisk': fridaMagisk,
      'keyLogger': keyLogger,
      'exemptedHosts': exemptedHosts,
    };
  }
}