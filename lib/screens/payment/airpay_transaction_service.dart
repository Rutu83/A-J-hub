import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/utils/configs.dart';

/// Airpay Transaction Service
///
/// Handles posting transaction data to the backend for testing purposes.
/// Uses the local/configured URL from configs.dart
class AirpayTransactionService {
  /// Posts a successful payment transaction to the backend
  static Future<Map<String, dynamic>?> postSuccessTransaction({
    required String orderId,
    required String planName,
    required double amount,
    required String transactionId,
    Map<String, dynamic>? airpayResponse,
  }) async {
    return _postTransaction(
      orderId: orderId,
      planName: planName,
      amount: amount,
      transactionId: transactionId,
      status: 'success',
      paymentMethod: 'airpay',
      airpayResponse: airpayResponse,
    );
  }

  /// Posts a failed payment transaction to the backend
  static Future<Map<String, dynamic>?> postFailedTransaction({
    required String orderId,
    required String planName,
    required double amount,
    String? transactionId,
    String? errorMessage,
    Map<String, dynamic>? airpayResponse,
  }) async {
    return _postTransaction(
      orderId: orderId,
      planName: planName,
      amount: amount,
      transactionId:
          transactionId ?? 'FAILED_${DateTime.now().millisecondsSinceEpoch}',
      status: 'failed',
      paymentMethod: 'airpay',
      errorMessage: errorMessage,
      airpayResponse: airpayResponse,
    );
  }

  /// Internal method to post transaction data
  static Future<Map<String, dynamic>?> _postTransaction({
    required String orderId,
    required String planName,
    required double amount,
    required String transactionId,
    required String status,
    required String paymentMethod,
    String? errorMessage,
    Map<String, dynamic>? airpayResponse,
  }) async {
    try {
      final String? authToken = appStore.token;
      if (authToken == null || authToken.isEmpty) {
        print('⚠️ Auth token is missing, skipping transaction post');
        return null;
      }

      // Using BASE_URL from configs.dart (which points to local server for testing)
      final String apiUrl = '${BASE_URL}airpay/transactions';

      final payload = {
        'order_id': orderId,
        'plan_name': planName,
        'amount': amount,
        'transaction_id': transactionId,
        'status': status,
        'payment_method': paymentMethod,
        'user_email': appStore.Email,
        'user_name': appStore.Name,
        'user_phone': appStore.number,
        'error_message': errorMessage,
        'airpay_response': airpayResponse,
        'transaction_date': DateTime.now().toIso8601String(),
      };

      print('--- 🚀 [POST] Airpay Transaction 🚀 ---');
      print('URL: $apiUrl');
      print('Payload: ${json.encode(payload)}');
      print('--------------------------------------');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: json.encode(payload),
      );

      print('--- 👽 [POST] Response 👽 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-----------------------------');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('⚠️ Failed to post transaction: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('--- 💥 [POST] Transaction Failed 💥 ---');
      print('Error: $e');
      print('---------------------------------------');
      return null; // Don't throw - just log and continue
    }
  }

  /// Helper method to convert Airpay SDK response to Map
  static Map<String, dynamic>? parseAirpayResponse(dynamic response) {
    if (response == null) return null;

    try {
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String) {
        return json.decode(response);
      } else {
        return {'raw_response': response.toString()};
      }
    } catch (e) {
      return {'raw_response': response.toString()};
    }
  }
}
