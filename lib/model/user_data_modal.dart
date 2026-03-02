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
    if (this.id != null) data['id'] = this.id;
    if (this.username != null) data['username'] = this.username;
    if (this.email != null) data['email'] = this.email;
    if (this.role != null) data['role'] = this.role;
    if (this.status != null) data['status'] = this.status;
    if (this.subscriptionPlanId != null)
      data['subscription_plan_id'] = this.subscriptionPlanId;

    return data;
  }
}
