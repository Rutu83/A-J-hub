package com.ajhubdesignapp.ajhub_app // <-- YOUR PACKAGE NAME

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails

class MainActivity: FlutterActivity() {
    // Use a unique channel name related to your app
    private val CHANNEL = "com.ajhubdesignapp.ajhub_app/referral"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getInstallReferrer") {
                getInstallReferrerInfo(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstallReferrerInfo(result: MethodChannel.Result) {
        val referrerClient: InstallReferrerClient = InstallReferrerClient.newBuilder(this).build()

        referrerClient.startConnection(object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                when (responseCode) {
                    InstallReferrerClient.InstallReferrerResponse.OK -> {
                        try {
                            val response: ReferrerDetails = referrerClient.installReferrer
                            val referrerUrl: String = response.installReferrer
                            // Send the raw referrer string back to Flutter
                            result.success(referrerUrl)
                        } catch (e: Exception) {
                            result.error("API_ERROR", "Failed to get referrer details.", e.toString())
                        } finally {
                            referrerClient.endConnection()
                        }
                    }
                    InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED -> {
                        result.error("NOT_SUPPORTED", "Install Referrer API not supported.", null)
                        referrerClient.endConnection()
                    }
                    InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                        result.error("SERVICE_UNAVAILABLE", "Could not connect to the service.", null)
                        referrerClient.endConnection()
                    }
                    else -> {
                        result.error("OTHER_ERROR", "An unknown error occurred.", null)
                        referrerClient.endConnection()
                    }
                }
            }

            override fun onInstallReferrerServiceDisconnected() {
                // This is called if the service is disconnected.
                // You can optionally try to reconnect. For this example, we do nothing.
            }
        })
    }
}