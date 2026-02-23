import 'package:airpay_flutter_v4/screens/airpay_home_intent.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/utils/colors.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:airpay_flutter_v4/model/UserRequest.dart';
import 'package:nb_utils/nb_utils.dart';

class FixedAirpayScreen extends StatefulWidget {
  final int planId;
  final String period;
  final String amount;

  const FixedAirpayScreen({
    super.key,
    required this.planId,
    required this.period,
    required this.amount,
  });

  @override
  State<FixedAirpayScreen> createState() => _FixedAirpayScreenState();
}

class _FixedAirpayScreenState extends State<FixedAirpayScreen> {
  bool isLoading = true;
  String? errorMessage;
  UserRequest? userRequest;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      // Generate unique payment ID
      final paymentId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      print('>>> [FixedAirpay] Starting Payment Initialization');
      print('>>> [FixedAirpay] Generated Payment ID: $paymentId');
      print(
          '>>> [FixedAirpay] Plan ID: ${widget.planId}, Period: ${widget.period}, Amount: ${widget.amount}');

      // Call your backend to get payment details
      print('>>> [FixedAirpay] Calling backend initiateAirpayPayment...');
      final response = await initiateAirpayPayment(
        paymentId: paymentId,
        planId: widget.planId,
        period: widget.period,
        chmod: 'upi',
      );
      print('>>> [FixedAirpay] Backend Response: $response');

      if (response['status'] == true) {
        // Extract the data from backend response
        final data = response;

        // Create UserRequest object for the SDK
        userRequest = UserRequest(
          // Basic merchant details
          mercid: data['merchant_id'] ?? '',
          privatekey: data['secret_key'] ?? '',

          // OAuth credentials
          client_id: data['client_id'] ?? '',
          client_secret: data['client_secret'] ?? '',
          grant_type: data['grant_type'] ?? 'client_credentials',

          // AES encryption key
          aesDeskey: data['aes_key'] ?? '',

          // Order details
          orderid: data['order_id'] ?? '',
          amount: data['amount']?.toString() ?? widget.amount,
          currency: '356', // INR numeric code
          isocurrency: 'INR',
          sb_amount: '', // Blank as per Airpay team
          chmod: 'upi',
          // Buyer details
          buyerEmail: data['buyer_email'] ?? '',
          buyerPhone: data['buyer_phone'] ?? '',
          buyerFirstName: data['buyer_firstname'] ?? 'Customer',
          buyerLastName: data['buyer_lastname'] ?? '',
          buyerAddress: data['buyer_address'] ?? 'India',
          buyerCity: data['buyer_city'] ?? 'City',
          buyerState: data['buyer_state'] ?? 'State',
          buyerCountry: data['buyer_country'] ?? 'India',
          buyerPinCode: '000000',

          // URLs
          protoDomain: (data['is_staging'] ?? true)
              ? '${BASE_URL}pay/v4/'
              : '${BASE_URL}pay/v4/',

          successUrl: '$BASE_URL/api/airpay/success',
          failedUrl: '$BASE_URL/',

          // App customization
          appName: 'AJ Hub',
          colorCode: '0xFF${primaryColor.value.toRadixString(16).substring(2)}',

          // Environment
          isStaging: data['is_staging'] ?? true,

          // Transaction subtype (optional, for subscriptions)
          txnsubtype: null,

          // Other SB parameters blank
          sb_frequency: '',
          sb_isrecurring: '',
          sb_maxamount: '',
          sb_nextrundate: '',
          sb_period: '',
          sb_recurringcount: '',
          sb_retryattempts: '',
        );

        print('>>> [FixedAirpay] UserRequest Created:');
        print('    Merchant ID: ${userRequest?.mercid}');
        print('    Order ID: ${userRequest?.orderid}');
        print('    Amount: ${userRequest?.amount}');
        print('    Currency: ${userRequest?.currency}');
        print('    ISOCurrency: ${userRequest?.isocurrency}');
        print('    Buyer Email: ${userRequest?.buyerEmail}');
        print('    Buyer Phone: ${userRequest?.buyerPhone}');
        print(
            '    Buyer Name: ${userRequest?.buyerFirstName} ${userRequest?.buyerLastName}');
        print('    SBAmount: ${userRequest?.sb_amount}');
        print('    ProtoDomain: ${userRequest?.protoDomain}');
        print('    Success URL: ${userRequest?.successUrl}');
        print('    Failed URL: ${userRequest?.failedUrl}');
        print('    Chmod: ${userRequest?.chmod}');

        setState(() {
          isLoading = false;
        });
      } else {
        print('>>> [FixedAirpay] Backend status is FALSE');
        print(
            '>>> [FixedAirpay] Error Message from Backend: ${response['message']}');
        setState(() {
          errorMessage = response['message'] ?? 'Failed to initialize payment';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
      print('>>> [FixedAirpay] Init Catch Error: $e');
    }
  }

  void _handlePaymentResponse(bool success, dynamic response) {
    print('>>> [FixedAirpay] _handlePaymentResponse called');
    print('>>> [FixedAirpay] Success: $success');
    try {
      print('>>> [FixedAirpay] Response Dump: $response');
    } catch (e) {
      print('>>> [FixedAirpay] Dump Error: $e');
    }

    Navigator.pop(context); // Go back to previous screen

    if (success) {
      toast('Payment Successful');
      // Handle successful payment
    } else {
      toast('Payment Failed', bgColor: Colors.red);
      // Handle failed payment
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Processing Payment'),
          backgroundColor: primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              16.height,
              Text('Initializing payment gateway...'),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Payment Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                16.height,
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                24.height,
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Use the official Airpay SDK widget
    return Scaffold(
      body: AirPay(
        user: userRequest!,
        closure: _handlePaymentResponse,
      ),
    );
  }
}
