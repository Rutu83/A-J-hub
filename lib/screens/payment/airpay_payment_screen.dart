import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:airpay_flutter_v4/airpay_package.dart';
import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/dashbord_screen.dart';
import 'package:ajhub_app/screens/payment/airpay_config.dart';

import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/payment/fixed_airpay_screen.dart';
// import 'package:ajhub_app/screens/payment/new_airpay_screen.dart';
import 'package:nb_utils/nb_utils.dart'; // For string validation extensions

/// Airpay Payment Screen
///
/// A beautiful, secure payment screen that integrates with Airpay payment gateway.
/// The UI matches the app's design language with red accents and Poppins font.
class AirpayPaymentScreen extends StatefulWidget {
  final double amount;
  final String planName;
  final String orderId;
  final int planId; // NEW
  final String period; // NEW: 'monthly' or 'yearly'

  const AirpayPaymentScreen({
    super.key,
    required this.amount,
    required this.planName,
    required this.orderId,
    required this.planId,
    required this.period,
  });

  @override
  State<AirpayPaymentScreen> createState() => _AirpayPaymentScreenState();
}

class _AirpayPaymentScreenState extends State<AirpayPaymentScreen> {
  bool _isProcessing = false;

  // API fetched details
  String _apiName = '';
  String _apiEmail = '';
  String _apiPhone = '';

  // User details from app store or API (Priority: API > AppStore > Default)
  String get _buyerFirstName => _apiName.isNotEmpty
      ? _apiName
      : (appStore.Name.isNotEmpty ? appStore.Name : 'User');

  String get _buyerLastName => ''; // Not stored separately

  String get _buyerEmail => _apiEmail.isNotEmpty
      ? _apiEmail
      : (appStore.Email.isNotEmpty ? appStore.Email : 'user@example.com');

  String get _buyerPhone => _apiPhone.isNotEmpty
      ? _apiPhone
      : (appStore.number.isNotEmpty ? appStore.number : '9999999999');

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userMap = await getUserDetail();

      if (mounted) {
        setState(() {
          _apiName = userMap['username'] ?? '';
          _apiEmail = userMap['email'] ?? '';
          _apiPhone = userMap['phone_number'] ?? '';
        });
      }
    } catch (e) {
      log('Failed to fetch user details for payment: $e');
      // Silently fail and rely on appStore/defaults
    }
  }

  /// Initiates Airpay payment
  Future<void> _initiatePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Fetch Merchant Credentials & Checksum from /initiate
      final credentials = await initiateAirpayPayment(
        paymentId: widget.orderId,
        planId: widget.planId,
        period: widget.period,
      );

      // Expected keys: merchant_id, username, password, secret_key, checksum
      final String merchantId = credentials['merchant_id'] ?? '';
      final String secretKey = credentials['secret_key'] ?? '';
      final String checksum = credentials['checksum'] ?? '';

      if (merchantId.isEmpty) {
        throw Exception("Merchant ID not found in initialization response.");
      }

      if (checksum.isEmpty) {
        throw Exception("Checksum not found in initialization response.");
      }

      // 2. Prepare UserRequest for Airpay SDK
      // Use address details from backend response to ensure checksum matches
      final user = UserRequest(
        privatekey: secretKey,
        checksum: checksum,
        mercid: merchantId,
        protoDomain: AirpayConfig.protoDomain,
        buyerFirstName: credentials['buyer_firstname'] ?? _buyerFirstName,
        buyerLastName: credentials['buyer_lastname'] ?? _buyerLastName,
        buyerEmail: credentials['buyer_email'] ?? _buyerEmail,
        buyerPhone: credentials['buyer_phone'] ?? _buyerPhone,
        buyerAddress: credentials['buyer_address'] ?? 'India',
        buyerPinCode: '000000',
        orderid: credentials['order_id'] ?? widget.orderId,
        amount: credentials['amount']?.toString() ?? widget.amount.toString(),
        buyerCity: credentials['buyer_city'] ?? 'City',
        buyerState: credentials['buyer_state'] ?? 'State',
        buyerCountry: credentials['buyer_country'] ?? 'India',
        currency: AirpayConfig.currency,
        isocurrency: AirpayConfig.isoCurrency,
        chmod: '',
        customvar: '',
        txnsubtype: '',
        wallet: '0',
        isStaging: credentials['is_staging'] ??
            true, // Dynamic from backend (true=test, false=live)
        successUrl: AirpayConfig.successUrl,
        failedUrl: AirpayConfig.failedUrl,
        appName: AirpayConfig.appName,
        colorCode: AirpayConfig.colorCode,
        // OAuth credentials from backend (required by SDK)
        client_id: credentials['client_id'] ?? '',
        client_secret: credentials['client_secret'] ?? '',
        grant_type: credentials['grant_type'] ?? 'client_credentials',
        aesDeskey: credentials['aes_key'] ?? '',
      );

      if (!mounted) return;

      // 3. Launch SDK

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FixedAirpayScreen(
            planId: widget.planId,
            period: widget.period,
            amount: widget.amount.toString(),
          ),
          // builder: (context) => NewAirpayScreen(
          //   user: user,
          //   onPaymentComplete: (status, response) =>
          //       _onPaymentComplete(status, response),
          // ),
        ),
      );
    } catch (e) {
      log('Payment Initialization Failed: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        _showFailureDialog("Initialization Error", e.toString());
      }
    }
  }

  /// Handles payment completion
  void _onPaymentComplete(bool isSuccess, dynamic response) {
    setState(() => _isProcessing = false);

    if (isSuccess) {
      _showSuccessDialog();
    } else {
      _showFailureDialog(isSuccess.toString(), response);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 48.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Payment Successful!',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your membership has been activated.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Go to Dashboard',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFailureDialog(String status, dynamic response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 48.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Payment Failed',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _initiatePayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Complete Payment',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PLAN SUMMARY CARD ---
            _buildPlanSummaryCard(),
            SizedBox(height: 20.h),

            // --- USER INFO CARD ---
            _buildUserInfoCard(),
            SizedBox(height: 20.h),

            // --- SECURITY BADGE ---
            _buildSecurityBadge(),
            SizedBox(height: 30.h),

            // --- PAY NOW BUTTON ---
            _buildPayButton(),
            SizedBox(height: 16.h),

            // --- TERMS TEXT ---
            Text(
              'By proceeding, you agree to our Terms & Conditions and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership, color: Colors.white, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  widget.planName,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount to Pay',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.person_outline,
            'Name',
            '$_buyerFirstName $_buyerLastName',
          ),
          _buildInfoRow(Icons.email_outlined, 'Email', _buyerEmail),
          _buildInfoRow(Icons.phone_outlined, 'Phone', _buyerPhone),
          _buildInfoRow(Icons.receipt_outlined, 'Order ID', widget.orderId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[500], size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.green, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'Secured by Airpay',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _initiatePayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE53935),
        disabledBackgroundColor: const Color(0xFFE53935).withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 4,
      ),
      child: _isProcessing
          ? SizedBox(
              height: 24.h,
              width: 24.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: Colors.white, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Pay ₹${widget.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}
