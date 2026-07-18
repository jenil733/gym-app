package com.example.gym

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val STEP_SERVICE_CHANNEL = "com.example.gym/step_service"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STEP_SERVICE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    try {
                        val intent = Intent(this, StepForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (error: Exception) {
                        result.error(
                            "STEP_SERVICE_START_FAILED",
                            error.message,
                            null,
                        )
                    }
                }
                "stop" -> {
                    stopService(Intent(this, StepForegroundService::class.java))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
