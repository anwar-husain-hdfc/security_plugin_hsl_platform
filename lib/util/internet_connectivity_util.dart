import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
class InternetConnectivityUtil {
  static Future<bool> internetStatus() async {
    try {
      List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    } on SocketException catch (e) {
      // Handle potential issues related to network connections
      if (kDebugMode) {
        print("HSL_SECURITY:: SocketException caught: $e");
      }
      return false;
    } catch (e) {
      // Handle any other exceptions that might occur
      if (kDebugMode) {
        print("HSL_SECURITY:: An error occurred while checking connectivity: $e");
      }
      return false;
    }
  }
}
