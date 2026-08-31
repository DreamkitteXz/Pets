package com.kayque.pets

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val installer = ApkInstaller(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ApkInstaller.CHANNEL
        ).setMethodCallHandler { call, result -> installer.handle(call, result) }
    }
}
