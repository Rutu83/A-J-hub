import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ajhub_app/utils/configs.dart';

/// Service for fetching subscription plans from the backend
class SubscriptionPlanService {
  /// Fetch all active subscription plans from the API
  static Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final String apiUrl = '${BASE_URL}subscription-plans';

      print('--- 🚀 [GET] Subscription Plans 🚀 ---');
      print('URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print('--- 👽 [GET] Response 👽 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('-----------------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['plans'] != null) {
          final List<dynamic> plansJson = data['plans'];
          return plansJson
              .map((json) => SubscriptionPlan.fromJson(json))
              .toList();
        }
      }

      // Return default plans if API fails
      print('⚠️ Failed to fetch plans, using defaults');
      return _getDefaultPlans();
    } catch (e) {
      print('--- 💥 [GET] Plans Failed 💥 ---');
      print('Error: $e');
      print('--------------------------------');
      return _getDefaultPlans();
    }
  }

  /// Default fallback plans if API is unavailable
  static List<SubscriptionPlan> _getDefaultPlans() {
    return [
      SubscriptionPlan(
        id: 0,
        name: 'Basic',
        slug: 'basic',
        description: 'Free plan with limited features',
        priceMonthly: 0,
        priceYearly: 0,
        features: [
          '5 Downloads/Day',
          'Basic Templates',
          'Watermark on Posters',
          'Limited Frames',
        ],
        isRecommended: false,
      ),
      SubscriptionPlan(
        id: 1,
        name: 'Starter',
        slug: 'starter',
        description: 'Great for individuals and small businesses',
        priceMonthly: 149,
        priceYearly: 299,
        features: [
          '50 Downloads/Day',
          'No Watermark',
          'Premium Templates',
          '10 Custom Frames',
          'Document Locker',
        ],
        isRecommended: false,
      ),
      SubscriptionPlan(
        id: 2,
        name: 'Pro',
        slug: 'pro',
        description: 'Best value for professional users',
        priceMonthly: 299,
        priceYearly: 499,
        features: [
          'Unlimited Downloads',
          'All Premium Templates',
          'Unlimited Custom Frames',
          'Priority Support',
          'Early Access to New Features',
          'Business Branding Tools',
        ],
        isRecommended: true,
      ),
    ];
  }
}

/// Model for subscription plan
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double priceMonthly;
  final double priceYearly;
  final List<String> features;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.features,
    required this.isRecommended,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      priceMonthly: (json['price_monthly'] ?? 0).toDouble(),
      priceYearly: (json['price_yearly'] ?? 0).toDouble(),
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      isRecommended: json['is_recommended'] ?? false,
    );
  }

  /// Check if this is a free plan
  bool get isFree => priceMonthly == 0 && priceYearly == 0;

  /// Get price for display based on billing cycle
  double getPrice(bool isYearly) => isYearly ? priceYearly : priceMonthly;

  /// Get period text
  String getPeriod(bool isYearly) => isYearly ? '/yr' : '/mo';
}
