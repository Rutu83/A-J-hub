class UserData {
  int? id;
  String? username;
  String? email;
  String? role;
  String? status;
  int? subscriptionPlanId; // NEW: which plan the user is on

  // Constructor
  UserData(
      {this.id,
      this.username,
      this.email,
      this.role,
      this.status,
      this.subscriptionPlanId});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      subscriptionPlanId: json['subscription_plan_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (role != null) data['role'] = role;
    if (status != null) data['status'] = status;
    if (subscriptionPlanId != null) {
      data['subscription_plan_id'] = subscriptionPlanId;
    }

    return data;
  }
}
