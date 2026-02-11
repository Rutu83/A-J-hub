import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralService {
  // Use the same unique channel name as in MainActivity.kt
  static const _platform =
      MethodChannel('com.ajhubdesignapp.ajhub_app/referral');
  static const _checkedReferrerKey = 'hasCheckedInstallReferrer';

  // This method gets the referral code from the Play Store Install Referrer.
  // It ensures it only runs ONCE per installation to avoid unnecessary checks.
  static Future<String?> getInstallReferrerCode() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have already processed the install referrer
    final bool hasChecked = prefs.getBool(_checkedReferrerKey) ?? false;
    if (hasChecked) {
      return null; // Don't check again
    }

    try {
      // Mark as checked immediately to prevent re-running
      await prefs.setBool(_checkedReferrerKey, true);

      // Invoke the native method to get the raw referrer string
      final String? referrer =
          await _platform.invokeMethod('getInstallReferrer');

      if (referrer != null && referrer.contains('referral_code=')) {
        // Use a dummy URI to easily parse the query parameters
        final Uri uri = Uri.parse('?$referrer');
        final String? code = uri.queryParameters['referral_code'];
        return code;
      }
    } on PlatformException catch (e) {
      print("Failed to get install referrer: '${e.message}'.");
      // It's okay to fail silently, as this is a background process.
    }
    return null;
  }
}
