import 'dart:async';
import 'dart:ui';
import 'package:airpay_flutter_v4/screens/airpay_home_intent.dart';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/utils/colors.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:airpay_flutter_v4/model/UserRequest.dart';
import 'package:nb_utils/nb_utils.dart';

class FixedAirpayScreen extends StatefulWidget {
  final int planId;
  final String period;
  final String amount;
  final Map<String, dynamic> paymentData; // Pre-fetched from backend

  const FixedAirpayScreen({
    super.key,
    required this.planId,
    required this.period,
    required this.amount,
    required this.paymentData,
  });

  @override
  State<FixedAirpayScreen> createState() => _FixedAirpayScreenState();
}

class _FixedAirpayScreenState extends State<FixedAirpayScreen> {
  bool isLoading = true;
  String? errorMessage;
  UserRequest? userRequest;
  bool _hasHandledSdkError = false;

  // App Links for catching the "Go to App" backend button
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Store original error handler to restore later
  bool Function(Object, StackTrace)? _originalOnError;

  @override
  void initState() {
    super.initState();

    _initDeepLinks();

    // Intercept unhandled async errors from the Airpay SDK
    // The SDK crashes at fetchDetails:394 with 'type String is not a subtype of type Map'
    // after payment completes. We catch this and auto-navigate back.
    _originalOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorStr = error.toString();
      final stackStr = stack.toString();

      // Detect the specific Airpay SDK crash
      if (stackStr.contains('fetchDetails') &&
          errorStr.contains(
              "type 'String' is not a subtype of type 'Map<String, dynamic>'")) {
        print(
            '>>> [FixedAirpay] Caught Airpay SDK fetchDetails error — auto-navigating back');
        if (!_hasHandledSdkError && mounted) {
          _hasHandledSdkError = true;
          // Auto pop and show success — payment was already processed on backend
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pop(context);
              _showSuccessPopup();
            }
          });
        }
        return true; // Error handled
      }

      // Pass other errors to original handler
      if (_originalOnError != null) {
        return _originalOnError!(error, stack);
      }
      return false;
    };

    _initializePayment();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('>>> [FixedAirpay] Received Deep Link: $uri');

      // If we got ajhub://open, it means user clicked "Go to App" on success page
      if (uri.scheme == 'ajhub' && uri.host == 'open') {
        if (!_hasHandledSdkError && mounted) {
          _hasHandledSdkError = true; // Prevent double trigger

          print('>>> [FixedAirpay] Deep link matches success return!');

          Navigator.pop(context); // Pop the WebView SDK
          _showSuccessPopup(); // Show native success popup
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    // Restore original error handler
    PlatformDispatcher.instance.onError = _originalOnError;
    super.dispose();
  }

  Future<void> _initializePayment() async {
    try {
      // Use the pre-fetched payment data from AirpayPaymentScreen
      // This avoids calling initiateAirpayPayment() again (which would create a duplicate DB entry)
      final data = widget.paymentData;
      print(
          '>>> [FixedAirpay] Starting Payment Initialization with pre-fetched data');
      print('>>> [FixedAirpay] Order ID: ${data['order_id']}');
      print(
          '>>> [FixedAirpay] Plan ID: ${widget.planId}, Period: ${widget.period}, Amount: ${widget.amount}');

      if (data['status'] == true) {
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
          // SECURITY: Always use amount from server response, never from UI widget
          // Using widget.amount as fallback would allow amount tampering via modified APK
          amount: data['amount']?.toString() ?? '0',
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

          successUrl: '${BASE_URL}api/airpay/response',
          failedUrl: '${BASE_URL}api/airpay/response',

          // App customization
          appName: 'AJ Hub',
          // Airpay expects a simple hex like #RRGGBB or just RRGGBB.
          // primaryColor.value.toRadixString(16) returns 'ffRRGGBB' (where ff is alpha).
          // We need just the 'RRGGBB'.
          colorCode:
              primaryColor.value.toRadixString(16).substring(2).toUpperCase(),

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
        print('>>> [FixedAirpay] Payment data status is FALSE');
        print('>>> [FixedAirpay] Error Message: ${data['message']}');
        setState(() {
          errorMessage = data['message'] ?? 'Failed to initialize payment';
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

    if (!mounted) return;

    Navigator.pop(context); // Go back to previous screen (pop the SDK)

    if (success) {
      _showSuccessPopup();
    } else {
      _showFailurePopup();
    }
  }

  void _showSuccessPopup() {
    // ✅ FIX: Capture the widget's own context BEFORE showing the dialog.
    // Inside the dialog's builder, `context` is a different (inner) context.
    // After pop(), the inner context is dead — so we must use `outerContext`
    // for navigation and mounted checks.
    final BuildContext outerContext = context;

    showGeneralDialog(
      context: outerContext,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated checkmark circle
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Title
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'Payment Successful! 🎉',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        'Your subscription has been activated.\nEnjoy premium features!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // 1️⃣ Close the success dialog (inner context)
                            Navigator.of(context).pop();

                            // 2️⃣ Show a "Please wait…" loading overlay on the
                            //    underlying screen using outerContext.
                            showDialog(
                              context: outerContext,
                              barrierDismissible: false,
                              barrierColor: Colors.black54,
                              builder: (_) => PopScope(
                                canPop: false,
                                child: Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 32, horizontal: 28),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 4,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.green.shade600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Activating your plan…',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please wait while we set things up for you.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            // 3️⃣ Wait 2s for IPN + pre-fetch fresh data
                            await Future.delayed(const Duration(seconds: 2));
                            try {
                              final userDetail = await getUserDetail();
                              final planId = userDetail['subscription_plan_id'];
                              final status = userDetail['status'] as String?;
                              if (status != null)
                                await appStore.setStatus(status);
                              await fetchAndStorePlanLimits(
                                  userPlanId: planId is int ? planId : null);
                            } catch (_) {}

                            // 4️⃣ Dismiss the loading overlay, then go to Dashboard
                            if (outerContext.mounted) {
                              Navigator.of(outerContext).pop(); // close loader
                              Navigator.of(outerContext).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const DashboardScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFailurePopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated X circle
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Failed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC62828),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Something went wrong.\nPlease try again.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
