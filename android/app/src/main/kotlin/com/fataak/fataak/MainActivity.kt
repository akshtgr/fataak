package com.fataak.fataak

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}