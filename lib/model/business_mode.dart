class BusinessModal {
  String? status;
  Business? business;

  BusinessModal({this.status, this.business});

  factory BusinessModal.fromJson(Map<String, dynamic> json) {
    return BusinessModal(
      status: json['status'],
      business: Business.fromJson(json['business']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'business': business?.toJson(),
    };
  }
}

class Business {
  int totalTeamCount;
  int totalIncome;
  int sponserIncome;
  int directTeamCount;
  int directIncome;
  List<dynamic> levelDownline; // Change to specific type if known
  DateTime createdAt;

  Business({
    required this.totalTeamCount,
    required this.totalIncome,
    required this.sponserIncome,
    required this.directTeamCount,
    required this.directIncome,
    required this.levelDownline,
    required this.createdAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      totalTeamCount: json['total_team_count'],
      totalIncome: json['total_income'],
      sponserIncome: json['sponser_income'],
      directTeamCount: json['direct_team_count'],
      directIncome: json['direct_income'],
      levelDownline: List<dynamic>.from(json['level_downline']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_team_count': totalTeamCount,
      'total_income': totalIncome,
      'sponser_income': sponserIncome,
      'direct_team_count': directTeamCount,
      'direct_income': directIncome,
      'level_downline': levelDownline,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
