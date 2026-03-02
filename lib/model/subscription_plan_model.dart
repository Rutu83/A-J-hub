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

/// Structured feature limits from the backend
class PlanLimits {
  final int personalFrame;
  final int businessFrame;
  final int lockerDocSave;
  final int downloadPosterDaily;
  final int sharePosterDaily;
  final int addBusiness;
  final bool businessSeminar;
  final bool planADay;

  const PlanLimits({
    this.personalFrame = 0,
    this.businessFrame = 0,
    this.lockerDocSave = 0,
    this.downloadPosterDaily = 0,
    this.sharePosterDaily = 0,
    this.addBusiness = 0,
    this.businessSeminar = false,
    this.planADay = false,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) => PlanLimits(
        personalFrame: (json['personal_frame'] as num?)?.toInt() ?? 0,
        businessFrame: (json['business_frame'] as num?)?.toInt() ?? 0,
        lockerDocSave: (json['locker_doc_save'] as num?)?.toInt() ?? 0,
        downloadPosterDaily:
            (json['download_poster_daily'] as num?)?.toInt() ?? 0,
        sharePosterDaily: (json['share_poster_daily'] as num?)?.toInt() ?? 0,
        addBusiness: (json['add_business'] as num?)?.toInt() ?? 0,
        businessSeminar: json['business_seminar'] == true,
        planADay: json['plan_a_day'] == true,
      );

  /// Returns true if the user can access this boolean feature
  bool canAccess(String feature) {
    switch (feature) {
      case 'business_seminar':
        return businessSeminar;
      case 'plan_a_day':
        return planADay;
      default:
        return false;
    }
  }

  /// Returns the numeric limit for a feature (0 = not allowed)
  int getLimit(String feature) {
    switch (feature) {
      case 'personal_frame':
        return personalFrame;
      case 'business_frame':
        return businessFrame;
      case 'locker_doc_save':
        return lockerDocSave;
      case 'download_poster_daily':
        return downloadPosterDaily;
      case 'share_poster_daily':
        return sharePosterDaily;
      case 'add_business':
        return addBusiness;
      default:
        return 0;
    }
  }

  static const PlanLimits empty = PlanLimits();
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String description;
  final num priceMonthly;
  final num priceYearly;
  final List<String> features;
  final PlanLimits limits;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.features,
    required this.limits,
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
        limits: json["limits"] != null && json["limits"] is Map
            ? PlanLimits.fromJson(json["limits"])
            : PlanLimits.empty,
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
