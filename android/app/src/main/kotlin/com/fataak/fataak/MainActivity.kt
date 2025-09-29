package com.fataak.fataak

// 1. ADD THIS IMPORT
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
// 2. ADD THIS IMPORT
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    // 3. ADD THIS ENTIRE onPostCreate METHOD
    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        // This is the line that enables edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}