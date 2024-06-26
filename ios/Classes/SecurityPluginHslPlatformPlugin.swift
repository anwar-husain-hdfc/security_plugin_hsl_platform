import Flutter
import UIKit

public class SecurityPluginHslPlatformPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "security_plugin_hsl_platform", binaryMessenger: registrar.messenger())
    let instance = SecurityPluginHslPlatformPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "root_detection":
       let jailBreakTestResult = JailBreakTestService().isJailBroken()
       print("IR_SECURITY: \(jailBreakTestResult.msg)")
       print("IR_SECURITY: \(jailBreakTestResult.failed)")
       result(jailBreakTestResult.failed)

    default:
      result(FlutterMethodNotImplemented)
      // TODO: Need to ask why they are sending false for any other call method as well from Yashwant.
      result(false)
    }
  }
}
