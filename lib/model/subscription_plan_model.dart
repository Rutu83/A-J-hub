import 'dart:convert';

/// Decodes the detailed plans response
List<SubscriptionPlan> subscriptionPlanFromJson(String str) {
  final jsonData = json.decode(str);
  // Handle both direct list or object with 'plans' key
  if (jsonData is Map<String, dynamic> && jsonData.containsKey('plans')) {
    return List<SubscriptionPlan>.from(
        jsonData['plans'].map((x) => SubscriptionPlan.fromJson(x)));
  } else if (jsonData is List) {
    return List<SubscriptionPlan>.from(
        jsonData.map((x) => SubscriptionPlan.fromJson(x)));
  } else {
    return [];
  }
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String description;
  final num priceMonthly;
  final num priceYearly;
  final List<String> features;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.features,
    required this.isRecommended,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        slug: json["slug"] ?? "",
        description: json["description"] ?? "",
        priceMonthly: json["price_monthly"] ?? 0,
        priceYearly: json["price_yearly"] ?? 0,
        features: json["features"] != null
            ? List<String>.from(json["features"].map((x) => x.toString()))
            : [],
        isRecommended: json["is_recommended"] == true ||
            json["is_recommended"] == 1 ||
            json["is_recommended"] == "1",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "description": description,
        "price_monthly": priceMonthly,
        "price_yearly": priceYearly,
        "features": List<dynamic>.from(features.map((x) => x)),
        "is_recommended": isRecommended,
      };
}
