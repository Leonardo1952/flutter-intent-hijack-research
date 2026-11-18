package dev.oxean.banconow

import android.app.Activity
import android.os.Process
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object IntentReporter {
    const val CHANNEL = "banconow/intent"

    fun register(engine: FlutterEngine, activity: Activity) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "describe") result.success(describe(activity)) else result.notImplemented()
        }
    }

    @Suppress("DEPRECATION")
    private fun describe(activity: Activity): Map<String, Any?> {
        val intent = activity.intent
        val extras = intent.extras
        return mapOf(
            "activity" to activity.javaClass.simpleName,
            "action" to intent.action,
            "data" to intent.dataString,
            "extras" to (extras?.keySet()?.associateWith { extras.get(it)?.toString() } ?: emptyMap<String, String?>()),
            "callingPackage" to activity.callingPackage,
            "ownPackage" to activity.packageName,
            "ownUid" to Process.myUid(),
        )
    }
}
