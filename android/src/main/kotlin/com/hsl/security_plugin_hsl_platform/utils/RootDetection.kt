package com.hsl.security_plugin_hsl_platform.utils

import android.content.Context
import android.content.pm.PackageManager
import java.io.BufferedReader
import java.io.File
import java.io.IOException
import java.io.InputStreamReader

object RootDetection {

    fun isDeviceRooted(): Boolean {
        return checkBuildTags() || checkRootManagementApps() || checkRootBinaries() || checkRootProps() || checkRootPathPermissions() || checkNativeLibrary() || checkPathEnvironment()
    }

    private fun checkBuildTags(): Boolean {
        val buildTags: String = android.os.Build.TAGS
        return buildTags.contains("test-keys")
    }

    private fun checkRootManagementApps(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
            "/magisk/.core/magisk.db",
            "/data/adb/magisk",
            "/data/local/tmp/magisk",
            "/data/adb/magisk.img"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootBinaries(): Boolean {
        val paths = arrayOf(
            "/system/xbin/su",
            "/system/bin/su",
            "/sbin/su",
            "/system/bin/.ext/.su",
            "/system/usr/we-need-root/su-backup",
            "/system/xbin/mu"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootProps(): Boolean {
        val properties = arrayOf(
            "ro.debuggable=1",
            "ro.secure=0"
        )
        for (property in properties) {
            val propValue = getSystemProperty(property.split("=")[0])
            if (propValue != null && propValue == property.split("=")[1]) {
                return true
            }
        }
        return false
    }

    private fun checkRootPathPermissions(): Boolean {
        val paths = arrayOf(
            "/system",
            "/system/bin",
            "/system/xbin",
            "/data/local/xbin",
            "/data/local/bin",
            "/system/sd/xbin"
        )
        for (path in paths) {
            val file = File(path)
            if (file.exists() && file.canWrite()) {
                return true
            }
        }
        return false
    }

    fun checkFridaOrMagisk(context: Context): Boolean {
        return checkFrida() || checkMagisk() || checkDangerousApps(context)
    }

    private fun checkFrida(): Boolean {
        var isFridaRunning = false

        val fridaFiles = arrayOf("/data/local/tmp/frida-gadget", "/data/local/tmp/frida-server", "/data/local/tmp/libfrida-gadget.so")
        for (file in fridaFiles) {
            if (File(file).exists()) {
                isFridaRunning = true
                break
            }
        }

        try {
            val process = Runtime.getRuntime().exec("ps")
            val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String? = bufferedReader.readLine()
            while (line != null) {
                if (line.contains("frida-server") || line.contains("frida-helper") || line.contains("gum-js-loop")) {
                    isFridaRunning = true
                    break
                }
                line = bufferedReader.readLine()
            }
        } catch (_: Exception) {
        }

        try {
            val process = Runtime.getRuntime().exec("lsof")
            val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String? = bufferedReader.readLine()
            while (line != null) {
                if (line.contains("libfrida-gadget.so")) {
                    isFridaRunning = true
                    break
                }
                line = bufferedReader.readLine()
            }
        } catch (_: Exception) {
        }

        if (!isFridaRunning) {
            try {
                val process = Runtime.getRuntime().exec("cat /proc/self/maps")
                val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
                var line: String? = bufferedReader.readLine()
                while (line != null) {
                    if (line.contains("frida")) {
                        isFridaRunning = true
                        break
                    }
                    line = bufferedReader.readLine()
                }
            } catch (_: Exception) {
            }
        }

        return isFridaRunning
    }

    private fun checkMagisk(): Boolean {
        var isMagiskRunning = false

        val magiskFiles = arrayOf(
            "/sbin/magisk",
            "/sbin/.core/mirror/magisk",
            "/sbin/.magisk/magisk",
            "/data/adb/magisk",
            "/data/adb/magisk.img",
            "/data/adb/magisk.db"
        )
        for (file in magiskFiles) {
            if (File(file).exists()) {
                isMagiskRunning = true
                break
            }
        }

        try {
            val process = Runtime.getRuntime().exec("ps")
            val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String? = bufferedReader.readLine()
            while (line != null) {
                if (line.contains("magisk")) {
                    isMagiskRunning = true
                    break
                }
                line = bufferedReader.readLine()
            }
        } catch (_: Exception) {
        }

        try {
            val process = Runtime.getRuntime().exec("lsof")
            val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String? = bufferedReader.readLine()
            while (line != null) {
                if (line.contains("magisk")) {
                    isMagiskRunning = true
                    break
                }
                line = bufferedReader.readLine()
            }
        } catch (_: Exception) {
        }

        if (!isMagiskRunning) {
            try {
                val process = Runtime.getRuntime().exec("cat /proc/self/maps")
                val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
                var line: String? = bufferedReader.readLine()
                while (line != null) {
                    if (line.contains("magisk")) {
                        isMagiskRunning = true
                        break
                    }
                    line = bufferedReader.readLine()
                }
            } catch (_: Exception) {
            }
        }

        return isMagiskRunning
    }

    private fun getSystemProperty(propName: String): String? {
        return try {
            val process = Runtime.getRuntime().exec("getprop $propName")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            reader.readLine()
        } catch (e: IOException) {
            null
        }
    }

    private fun checkDangerousApps(context: Context): Boolean {
        val dangerousApps = arrayOf(
            "com.noshufou.android.su",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.zachspong.temprootremovejb",
            "com.ramdroid.appquarantine",
            "com.topjohnwu.magisk"
        )
        for (packageName in dangerousApps) {
            try {
                val packageInfo = context.packageManager.getPackageInfo(packageName, 0)
                if (packageInfo != null) {
                    return true
                }
            } catch (e: PackageManager.NameNotFoundException) {
                // Ignore, app not found
            }
        }
        return false
    }

    private fun checkNativeLibrary(): Boolean {
        val libraries = arrayOf("libsu.so", "libsupol.so", "libsubst.so")
        for (lib in libraries) {
            try {
                val process = Runtime.getRuntime().exec("ls /system/lib")
                val bufferedReader = BufferedReader(InputStreamReader(process.inputStream))
                var line: String? = bufferedReader.readLine()
                while (line != null) {
                    if (line.contains(lib)) {
                        return true
                    }
                    line = bufferedReader.readLine()
                }
            } catch (e: Exception) {
                // Handle exception
            }
        }
        return false
    }

    private fun checkPathEnvironment(): Boolean {
        val paths = System.getenv("PATH")?.split(":")
        if (paths != null) {
            for (path in paths) {
                if (path.contains("su")) {
                    return true
                }
            }
        }
        return false
    }

}
