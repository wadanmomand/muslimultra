package com.muslimultra.muslim_ultra

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val WIDGETS_CHANNEL = "com.muslimultra.app/widgets"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGETS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updatePrayerWidget" -> {
                    PrayerWidgetProvider.updateAllWidgets(context)
                    result.success(true)
                }
                "updateAyahWidget" -> {
                    AyahWidgetProvider.updateAllWidgets(context)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
