package com.hsl.security_plugin_hsl_platform_example

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onPause() {
        window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onPause()
    }

    override fun onResume() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onResume()
    }
}
