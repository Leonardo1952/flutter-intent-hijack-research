package dev.oxean.banconow

import io.flutter.embedding.android.FlutterActivity

class SessionWidgetActivity : FlutterActivity() {
    override fun getCachedEngineId(): String = BankApplication.SESSION_ENGINE_ID
}
