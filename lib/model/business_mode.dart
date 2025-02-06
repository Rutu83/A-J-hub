class BusinessModal {
  String? status;
  Business? business;

  BusinessModal({this.status, this.business});

  factory BusinessModal.fromJson(Map<String, dynamic> json) {
    return BusinessModal(
      status: json['status'],
      business: json['business'] != null ? Business.fromJson(json['business']) : null,
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
  int totleUser;
  int totalTeamCount;
  double totalIncome;
  double sponserIncome;
  int directTeamCount;
  int directIncome;
  List<LevelDownline> levelDownline;
  DateTime createdAt;

  Business({
    required this.totleUser,
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
      totleUser: json['totle_user'] ?? 0,
      totalTeamCount: json['total_team_count'] ?? 0,
      totalIncome: (json['total_income'] is String)
          ? double.tryParse(json['total_income']) ?? 0.0
          : (json['total_income'] ?? 0.0).toDouble(),
      sponserIncome: (json['sponser_income'] is String)
          ? double.tryParse(json['sponser_income']) ?? 0.0
          : (json['sponser_income'] ?? 0.0).toDouble(),
      directTeamCount: json['direct_team_count'] ?? 0,
      directIncome: json['direct_income'] ?? 0,
      levelDownline: (json['level_downline'] as List<dynamic>?)
          ?.map((item) => LevelDownline.fromJson(item))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totle_user': totleUser,
      'total_team_count': totalTeamCount,
      'total_income': totalIncome,
      'sponser_income': sponserIncome,
      'direct_team_count': directTeamCount,
      'direct_income': directIncome,
      'level_downline': levelDownline.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class LevelDownline {
  int level;
  int userId;
  String username;
  String uid;
  int directTeamCount;
  int directIncome;
  double totalIncome;
  int totalTeamCount;
  DateTime createdAt;

  LevelDownline({
    required this.level,
    required this.userId,
    required this.username,
    required this.uid,
    required this.directTeamCount,
    required this.directIncome,
    required this.totalIncome,
    required this.totalTeamCount,
    required this.createdAt,
  });

  factory LevelDownline.fromJson(Map<String, dynamic> json) {
    return LevelDownline(
      level: json['level'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      uid: json['uid'] ?? '',
      directTeamCount: json['direct_team_count'] ?? 0,
      directIncome: json['direct_income'] ?? 0,
      totalIncome: (json['total_income'] is String)
          ? double.tryParse(json['total_income']) ?? 0.0
          : (json['total_income'] ?? 0.0).toDouble(),
      totalTeamCount: json['total_team_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'user_id': userId,
      'username': username,
      'uid': uid,
      'direct_team_count': directTeamCount,
      'direct_income': directIncome,
      'total_income': totalIncome,
      'total_team_count': totalTeamCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}