package dev.oxean.banconow

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class BankApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val engine = FlutterEngine(this)
        engine.navigationChannel.setInitialRoute("/session")
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        FlutterEngineCache.getInstance().put(SESSION_ENGINE_ID, engine)
    }

    companion object {
        const val SESSION_ENGINE_ID = "session_engine"
    }
}
