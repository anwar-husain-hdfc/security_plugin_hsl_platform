package com.hsl.security_plugin_hsl_platform

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import com.hsl.security_plugin_hsl_platform.utils.LOG_TAG_PLAY_INTEGRITY
import com.hsl.security_plugin_hsl_platform.utils.MEETS_STRONG_INTEGRITY_KEY
import com.hsl.security_plugin_hsl_platform.utils.RootDetection
import com.hsl.security_plugin_hsl_platform.utils.appverifier.IntegrityAPIProvider
import com.hsl.security_plugin_hsl_platform.utils.appverifier.OnIntegrityProviderCallback
import com.hsl.security_plugin_hsl_platform.utils.supportsHardwareBackedAttestation

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

/** SecurityPluginHslPlatformPlugin */
class SecurityPluginHslPlatformPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var applicationContext: Context
  companion object {
    //    private const val CHANNEL = "flutter.native/helper"
    private const val ROOT_DETECTION = "root_detection"
    private const val PLAY_INTEGRITY = "play_integrity"
    private const val EMULATOR__DETECTION = "emulator_detection"
    private const val APP_INTEGRITY = "app_integrity"
    private const val GET_CONFIG = "getConfig"
    private const val SHA_DETECTION = "sha_detection"
  }
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "security_plugin_hsl_platform")
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == ROOT_DETECTION) {
      result.success(RootDetection.isDeviceRooted())
    } else if (call.method == PLAY_INTEGRITY) {
      IntegrityAPIProvider.getInstance(applicationContext).initiateIntegrityDetection(object :
        OnIntegrityProviderCallback {
        override fun onSuccess(verdict: ArrayList<String>) {
          handleHardwareBackedAttestation(verdict)
          result.success(verdict)
        }

        override fun onError(throwable: Throwable) {
          val playIntegrityList = arrayListOf<String>()
          if (throwable.message?.contains("Network error") == true || throwable.message?.contains("-3") == true) {
            playIntegrityList.add("NETWORK_ERROR")
          }
          result.success(playIntegrityList)
        }
      })
    } else if (call.method == SHA_DETECTION) {
      // result.success(isAppSHAMatching())
    } else if(call.method == APP_INTEGRITY){
      result.success(isAppIntegrityPassed(context = applicationContext))
    } else if(call.method == EMULATOR__DETECTION){
      result.success(isEmulator())
    } else if (call.method == GET_CONFIG) {
      val config = mapOf(
        "fingerprint1" to BuildConfig.FINGERPRINT1,
        "fingerprint2" to BuildConfig.FINGERPRINT2,
        "fingerprint1_ir" to BuildConfig.FINGERPRINT1_IR,
        "fingerprint2_ir" to BuildConfig.FINGERPRINT2_IR,
      )
      result.success(config)
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun isAppIntegrityPassed(context: Context): Boolean {
    return RootDetection.checkFridaOrMagisk(context = applicationContext)
  }

  private fun handleHardwareBackedAttestation(verdict: ArrayList<String>) {
    // Check if the device supports hardware-backed attestation on Android S and above
    val isHardwareBackedAttestationSupported =
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && supportsHardwareBackedAttestation()
    if (isHardwareBackedAttestationSupported) {
      Log.d(LOG_TAG_PLAY_INTEGRITY, "Supports Hardware Backed Attestation")
      if (verdict.contains(MEETS_STRONG_INTEGRITY_KEY)) {
        Log.d(LOG_TAG_PLAY_INTEGRITY, "MEETS_STRONG_INTEGRITY_KEY FOUND")
      } else {
        Log.d(LOG_TAG_PLAY_INTEGRITY, "MEETS_STRONG_INTEGRITY_KEY NOT FOUND")
      }
    } else {
      Log.d(LOG_TAG_PLAY_INTEGRITY, "Hardware Backed Attestation Not Supported")
      if (!verdict.contains(MEETS_STRONG_INTEGRITY_KEY)) {
        // Adding a key to not block devices that do not support this feature
        verdict.add(MEETS_STRONG_INTEGRITY_KEY)
      }
    }
  }

  /*  private fun isAppSHAMatching(): Boolean {
      try {
        val info: PackageInfo = getPackageManager()
          .getPackageInfo(BuildConfig.APPLICATION_ID, PackageManager.GET_SIGNATURES)
        for (signature in info.signatures) {
          val md: MessageDigest = MessageDigest.getInstance("SHA256")
          md.update(signature.toByteArray())
          val digest: ByteArray = md.digest()
          val toRet: java.lang.StringBuilder = java.lang.StringBuilder()
          for (i in digest.indices) {
            if (i != 0) toRet.append(":")
            val b = digest[i].toInt() and 0xff
            val hex: String = java.lang.Integer.toHexString(b)
            if (hex.length == 1) toRet.append("0")
            toRet.append(hex)
          }
          if(toRet.toString().equals(BuildConfig.SHA256, ignoreCase = true)) {
            System.out.println("MSDKGFF inside if :: ${"SHA256" + " " + toRet.toString()}")
            return true
          } else {
            return false
          }
          System.out.println("MSDKGFF :: ${"SHA256" + " " + toRet.toString()}")
        }
      } *//*catch (e1: NameNotFoundException) {
            System.out.println("MSDKGFF :: name not found $e1")
        } *//*catch (e: NoSuchAlgorithmException) {
      System.out.println("MSDKGFF :: no such an algorithm $e")
    } catch (e: java.lang.Exception) {
      System.out.println("MSDKGFF :: exception $e")
    }
    return false
  }*/

/*  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }*/

  private fun isEmulator(): Boolean {
    var result = Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.contains("vbox") ||
            Build.FINGERPRINT.contains("test-keys") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for x86") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("vbox86") ||
            Build.PRODUCT.contains("sdk") ||
            Build.PRODUCT.contains("google_sdk") ||
            Build.PRODUCT.contains("sdk_x86") ||
            Build.PRODUCT.contains("vbox86p") ||
            Build.BOARD.lowercase(Locale.getDefault()).contains("nox") ||
            Build.BOOTLOADER.lowercase(Locale.getDefault()).contains("nox") ||
            Build.HARDWARE.lowercase(Locale.getDefault()).contains("nox") ||
            Build.SERIAL.lowercase(Locale.getDefault())
              .contains("nox") || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith(
      "generic"
    ) || "google_sdk" == Build.PRODUCT
//    result = result or (Settings.Secure.getString(
//      contentResolver,
//      Settings.Secure.ANDROID_ID
//    ) == null)
    return result
  }
}
