package com.ti23a4.parkircepat

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deepLinkChannel = "parkir_cepat/deep_link"
    private var methodChannel: MethodChannel? = null
    private var latestDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        latestDeepLink = intent?.dataString
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deepLinkChannel)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getLatestDeepLink" -> result.success(latestDeepLink)
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        latestDeepLink = intent.dataString
        latestDeepLink?.let { methodChannel?.invokeMethod("onDeepLink", it) }
    }
}
