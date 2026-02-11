/// Airpay Payment Gateway Configuration
///
/// Replace these placeholder values with your actual Airpay merchant credentials
/// obtained from your Airpay merchant dashboard.

class AirpayConfig {
  // --- MERCHANT CREDENTIALS ---
  // Credentials are now fetched dynamically from the backend (/api/airpay/initiate)

  // --- DOMAIN & URLs ---

  // --- DOMAIN & URLs ---
  static const String protoDomain = 'https://payments.airpay.co.in/';
  static const String successUrl = 'https://www.airpay.co.in/success';
  static const String failedUrl = 'https://www.airpay.co.in/failed';

  // --- ENVIRONMENT ---
  /// Set to true for sandbox/testing, false for production
  static const bool isSandbox = true;

  // --- APP CONFIG ---
  static const String appName = 'Aj Hub';
  static const String colorCode = '0xFFE53935'; // Red accent color

  // --- CURRENCY ---
  static const String currency = '356'; // INR currency code
  static const String isoCurrency = 'INR';
}
