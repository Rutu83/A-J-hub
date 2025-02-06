class UserData {
  int? id;
  String? username;
  String? email;
  String? role;
  String? status;

  // Constructor
  UserData({this.id, this.username, this.email, this.role, this.status});


  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['status'] = status;
    return data;
  }
}
