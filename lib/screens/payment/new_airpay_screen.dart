import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:airpay_flutter_v4/model/UserRequest.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'airpay_service.dart';
import 'airpay_qr_screen.dart';

class NewAirpayScreen extends StatefulWidget {
  final UserRequest user;
  final Function(bool isSuccess, dynamic response)? onPaymentComplete;

  const NewAirpayScreen({Key? key, required this.user, this.onPaymentComplete})
      : super(key: key);

  @override
  State<NewAirpayScreen> createState() => _NewAirpayScreenState();
}

class _NewAirpayScreenState extends State<NewAirpayScreen> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  String? _errorMessage;

  // State for the POST request
  String? _postUrl;
  String? _postDataBody; // x-www-form-urlencoded body

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      // 1. Determine URLs
      final isStaging = widget.user.isStaging ?? false;
      final oauthUrl = isStaging
          ? 'https://kraken.airpay.ninja/mockbin/pay/v4/api/oauth2/'
          : 'https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2/';

      _postUrl = isStaging
          ? "https://payments.airpay.ninja/pay/v4/"
          : "https://payments.airpay.co.in/pay/v4/";

      // 2. Fetch OAuth Token
      final token = await _fetchOAuthToken(oauthUrl);
      if (token == null) {
        throw Exception("Failed to retrieve access token.");
      }

      // 3. Prepare Payment Data
      await _preparePaymentPostData(token);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _fetchOAuthToken(String url) async {
    final user = widget.user;
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Data for Checksum (Sorted Keys)
    final checksumMap = {
      "client_id": user.client_id,
      "client_secret": user.client_secret,
      "grant_type": user.grant_type,
      "merchant_id": user.mercid,
    };

    // Checksum = SHA256(SortedValues + Date)
    final allDataString =
        AirpayService.generateAllDataString(checksumMap) + currentDate;
    final checksum = AirpayService.generateChecksum(allDataString, "");

    final payload = {
      "client_id": user.client_id,
      "client_secret": user.client_secret,
      "grant_type": user.grant_type,
      "merchant_id": user.mercid,
    };

    // Encrypt payload
    final key = user.aesDeskey ?? "";
    final encryptedPayload =
        AirpayService.encryptData(jsonEncode(payload), key);

    final requestBody = {
      'merchant_id': user.mercid,
      'checksum': checksum,
      'encdata': encryptedPayload
    };

    print(">>> [NewAirpay] Fetching Token from $url");

    try {
      final response = await _dio.post(url,
          data: requestBody,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200 && response.data != null) {
        // Response is { "response": "ENCRYPTED_STRING" }
        // Or sometimes directly JSON? Docs say standard response structure is used.
        // Let's assume MerchantResponse wrapper or map.
        var responseData = response.data;
        String? encryptedResp;

        if (responseData is Map && responseData.containsKey('response')) {
          encryptedResp = responseData['response'];
        } else if (responseData is String) {
          // Try parsing json
          try {
            var json = jsonDecode(responseData);
            encryptedResp = json['response'];
          } catch (_) {
            // Raw string might be the response if format is weird?
          }
        }

        if (encryptedResp != null) {
          final decrypted = AirpayService.decryptData(encryptedResp, key);
          print(">>> [NewAirpay] Token Decrypted: $decrypted");
          final json = jsonDecode(decrypted);
          if (json['status'] == '200' || json['status'] == 'success') {
            return json['data']
                ['access_token']; // Adjust path based on TokenData model
            // TokenData usually: { "status": "200", "message": "...", "data": { "access_token": "..." } }
          }
        }
      }
    } catch (e) {
      print(">>> [NewAirpay] Token Fetch Error: $e");
    }
    return null;
  }

  Future<void> _preparePaymentPostData(String token) async {
    final user = widget.user;
    // Date format must be yyyy-MM-dd
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Data map for checksum and encryption
    // IMPORTANT: UPI INTENT logic
    // "upi_intent": "Y"

    final Map<String, dynamic> dataParams = {
      "amount": user.amount,
      "buyer_address": user.buyerAddress,
      "buyer_city": user.buyerCity,
      "buyer_country": user.buyerCountry,
      "buyer_email": user.buyerEmail,
      "buyer_firstname": user.buyerFirstName,
      "buyer_lastname": user.buyerLastName,
      "buyer_phone": user.buyerPhone,
      "buyer_pincode": user.buyerPinCode ?? "000000",
      "buyer_state": user.buyerState,
      "currency_code": "INR",
      "iso_currency": user.isocurrency ?? "INR",
      "orderid": user.orderid,
      "sb_amount": user.amount ?? "0",
      "upi_intent": "Y", // Enable UPI
      "app_intent": "Y", // Enable App Intent
    };

    // Generate Checksum
    // Docs: SHA256(Sorted Params + Date)
    // We'll use the service helper which sorts the keys.
    // Ensure "upi_intent" and "app_intent" are included if they are in the encryption map.
    // NOTE: The previous code was: AirpayService.generateAllDataString(dataParams)
    // This helper ALREADY sorts the keys.
    // Double check: generateAllDataString sorts keys alphabetically.
    // Checksum = SHA256(value1 + value2 + ... + date)

    // Let's verify if "app_intent" or "upi_intent" should be part of the checksum.
    // If they are sent in encdata, they MUST be in checksum.

    // USE BACKEND-GENERATED CHECKSUM (Don't regenerate!)
    final checksum = user.checksum ?? "";

    print(">>> [NewAirpay] Using backend checksum: $checksum");

    // Encrypt Data
    final jsonString = jsonEncode(dataParams);
    final key = user.aesDeskey ?? "";
    final encryptedData = AirpayService.encryptData(jsonString, key);

    final protocolDomain = user.protoDomain ?? "https://sanctum.airpay.co.in";
    final merDom =
        base64Encode(utf8.encode(protocolDomain.replaceAll(RegExp(r'/$'), '')))
            .trim();

    // Final POST Data
    final Map<String, String> postParams = {
      "encdata": encryptedData,
      "checksum": checksum,
      "merchant_id": user.mercid ?? "",
      "privatekey": user.privatekey ?? "",
      "mer_dom": merDom
    };

    // Append token to URL
    _postUrl = "$_postUrl?token=$token";

    // Encode body
    _postDataBody = postParams.entries
        .map((e) =>
            "${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}")
        .join("&");

    print(">>> [NewAirpay] Ready to load: $_postUrl");
  }

  Future<void> _testQrGeneration() async {
    try {
      print(">>> [NewAirpay] Starting QR Generation Test...");
      // 1. URLs
      final isStaging = widget.user.isStaging ?? false;
      final oauthUrl = isStaging
          ? 'https://kraken.airpay.ninja/mockbin/pay/v4/api/oauth2/'
          : 'https://kraken.airpay.co.in/airpay/pay/v4/api/oauth2/';

      // 2. Token
      final token = await _fetchOAuthToken(oauthUrl);
      if (token == null) {
        print(">>> [NewAirpay] Token failed.");
        return;
      }

      // 3. API URL
      final baseUrl = isStaging
          ? 'https://kraken.airpay.ninja/airpay/pay/v4/api/generateorder'
          : 'https://kraken.airpay.co.in/airpay/pay/v4/api/generateorder';

      final qrUrl = "$baseUrl/?token=$token";

      // 4. Payload (Same as standard payment)
      final user = widget.user;
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final Map<String, dynamic> dataParams = {
        "amount": user.amount,
        "buyer_address": user.buyerAddress,
        "buyer_city": user.buyerCity,
        "buyer_country": user.buyerCountry,
        "buyer_email": user.buyerEmail,
        "buyer_firstname": user.buyerFirstName,
        "buyer_lastname": user.buyerLastName,
        "buyer_phone": user.buyerPhone,
        "buyer_pincode": user.buyerPinCode ?? "000000",
        "buyer_state": user.buyerState,
        "currency_code": "INR",
        "iso_currency": user.isocurrency ?? "INR",
        "orderid":
            "${user.orderid}_QR", // Append QR to avoid duplicate order error if any
        "sb_amount": user.amount ?? "0", // Same as amount, not null
        "upi_intent": "Y",
        "app_intent": "Y",
      };

      // OFFICIAL AIRPAY CHECKSUM (from docs)
      // The checksum must include ALL params being sent
      final checksum =
          AirpayService.generateAllDataString(dataParams) + currentDate;
      final checksumHash = AirpayService.generateChecksum(checksum, "");

      print(">>> [QR Checksum] Official method - Data: $dataParams");
      print(">>> [QR Checksum] Official method - String: $checksum");
      print(">>> [QR Checksum] Official method - Final: $checksumHash");

      final key = user.aesDeskey ?? "";
      final encryptedData =
          AirpayService.encryptData(jsonEncode(dataParams), key);

      final protocolDomain = user.protoDomain ?? "https://sanctum.airpay.co.in";
      final merDom = base64Encode(
              utf8.encode(protocolDomain.replaceAll(RegExp(r'/$'), '')))
          .trim();

      final Map<String, dynamic> postBody = {
        "encdata": encryptedData,
        "checksum": checksumHash,
        "merchant_id": user.mercid ?? "",
        "privatekey": user.privatekey ?? "",
        "mer_dom": merDom
      };

      print(">>> [NewAirpay] Sending QR Request to $qrUrl");

      final response = await _dio.post(qrUrl,
          data: postBody,
          options: Options(contentType: Headers.formUrlEncodedContentType));

      print(">>> [NewAirpay] QR Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = response.data; // Map or String
        String? encryptedResp;
        if (responseData is Map) {
          encryptedResp = responseData['response'];
        }

        if (encryptedResp != null) {
          final decrypted = AirpayService.decryptData(encryptedResp, key);
          print(">>> [NewAirpay] QR Decrypted: $decrypted");

          // Parse JSON
          // Expected: {"status": "success", "data": { "qr_code": "..." } } or similar
          // The user's successful log showed: {merchant_id: ..., response: ...}
          // Wait, the "QR Data" logged in step 293 was the *outer* wrapper.
          // Inside 'response' is the encrypted string.
          // Inside decrypted string, we expect the QR code content.

          try {
            final json = jsonDecode(decrypted);
            // Check for QR content
            // Since I don't have the exact structure of successful QR response,
            // I'll grab what looks like a QR string.
            // It might be 'upi://...' or a url.

            // Let's assume it's in 'data' -> 'qr_code' or just 'qr_code'
            // Or maybe the whole json string IS the QR payload? Unlikely.

            // If "status_code" is "200"
            if (json['status_code'] == '200' || json['status'] == 'success') {
              // Look for QR string.
              // If it's a UPI Intent, we can show it as QR.
              // Let's dump usage to AirpayQrScreen and let it render whatever string it gets.
              // But effectively we need a STRING to render.

              String qrString = "";
              if (json['data'] is Map) {
                qrString = json['data']['start_transaction_id'] ??
                    json['data']['qr_code'] ??
                    "";
                // Wait, if it returns a transaction ID, we might need to construct the UPI string?
                // "upi://pay?pa=..."
                // Documentation says "QR Code generation". It should return the QR string.
              } else if (json['data'] is String) {
                qrString = json['data'];
              }

              // Fallback: If we can't find it, show the whole decrypted string for debugging
              if (qrString.isEmpty) qrString = decrypted;

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AirpayQrScreen(
                      qrData: qrString,
                      amount: user.amount ?? "0",
                    ),
                  ),
                );
              }
            } else {
              Fluttertoast.showToast(msg: "QR Gen Failed: ${json['message']}");
            }
          } catch (e) {
            print(">>> [NewAirpay] JSON Parse Error: $e");
            Fluttertoast.showToast(msg: "Invalid QR Response");
          }
        }
      }
    } catch (e) {
      print(">>> [NewAirpay] QR Test Failed: $e");
      Fluttertoast.showToast(msg: "QR Generation Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
          appBar: AppBar(title: Text("Payment Error")),
          body:
              Center(child: Text(_errorMessage!, textAlign: TextAlign.center)));
    }

    if (_isLoading) {
      return Scaffold(
          body: Center(
              child: SpinKitFadingCircle(color: Colors.blue, size: 50.0)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Secure Payment"),
        backgroundColor: Color(0xFFE53935), // Match app theme
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testQrGeneration,
        child: Icon(Icons.qr_code),
        tooltip: "Test QR Generation",
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri(_postUrl!),
            method: 'POST',
            body: Uint8List.fromList(utf8.encode(_postDataBody!)),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;

          // Allow standard protocols
          if (["http", "https", "file", "chrome", "data", "javascript", "about"]
              .contains(uri.scheme)) {
            return NavigationActionPolicy.ALLOW;
          }

          // Handle UPI and other external apps
          try {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          } catch (e) {
            print("Could not launch $uri: $e");
            // Optionally show toast "App not installed"
            Fluttertoast.showToast(
              msg: "App not installed for this payment method",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
            return NavigationActionPolicy.CANCEL;
          }
        },
        onLoadStop: (controller, url) {
          // Check for success/failure URLs to close the screen
          // You can implement this based on your return URL logic
        },
      ),
    );
  }
}
