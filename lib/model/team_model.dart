class TeamModel {
  List<User> users;

  TeamModel({required this.users});

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      users: List<User>.from(json['users'].map((user) => User.fromJson(user))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}

class User {
  int userId;
  String username;
  String email;
  int? activationId;
  int roleId;
  int parentId;
  int sponcerId;
  int stateId;
  int? zoneId;
  int districtId;
  int countryId;
  String uid;
  String dob;
  String gender;
  String phoneNumber;
  String referralCode;
  String? subscriptionStartDate;
  String? subscriptionEndDate;
  String? kycStatus;
  String createdAt;
  String updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.activationId,
    required this.roleId,
    required this.parentId,
    required this.sponcerId,
    required this.stateId,
    this.zoneId,
    required this.districtId,
    required this.countryId,
    required this.uid,
    required this.dob,
    required this.gender,
    required this.phoneNumber,
    required this.referralCode,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.kycStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      activationId: json['activation_id'],
      roleId: json['role_id'] ?? 0,
      parentId: json['parentId'] ?? 0,
      sponcerId: json['sponcer_id'] ?? 0,
      stateId: json['state_id'] ?? 0,
      zoneId: json['zone_id'],
      districtId: json['district_id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      uid: json['Uid'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      referralCode: json['referral_code'] ?? '',
      subscriptionStartDate: json['subscription_start_date'],
      subscriptionEndDate: json['subscription_end_date'],
      kycStatus: json['kyc_status'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'activation_id': activationId,
      'role_id': roleId,
      'parentId': parentId,
      'sponcer_id': sponcerId,
      'state_id': stateId,
      'zone_id': zoneId,
      'district_id': districtId,
      'country_id': countryId,
      'Uid': uid,
      'dob': dob,
      'gender': gender,
      'phone_number': phoneNumber,
      'referral_code': referralCode,
      'subscription_start_date': subscriptionStartDate,
      'subscription_end_date': subscriptionEndDate,
      'kyc_status': kycStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
