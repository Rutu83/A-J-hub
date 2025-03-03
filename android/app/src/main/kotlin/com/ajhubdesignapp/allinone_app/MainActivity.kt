package com.ajhubdesignapp.ajhub_app // Ensure this matches your actual package name

import android.content.Intent
import android.media.MediaScannerConnection // Add this import
import android.net.Uri
import android.util.Log // Add this import for Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ajhubdesignapp.ajhub_app/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "refreshGallery") {
                val filePath = call.argument<String>("filePath")
                refreshGallery(filePath)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun refreshGallery(filePath: String?) {
        if (filePath != null) {
            MediaScannerConnection.scanFile(this, arrayOf(filePath), null) { path, uri ->
                Log.d("Gallery Refresh", "Scanned $path:")
                Log.d("Gallery Refresh", "-> uri=$uri")
            }
        }
    }
}




























