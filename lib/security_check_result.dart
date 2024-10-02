import 'device_security_status.dart';

class SecurityCheckResult {
  DeviceSecurityStatus status;
  final List<String> messages;

  SecurityCheckResult(this.status, this.messages);
}
