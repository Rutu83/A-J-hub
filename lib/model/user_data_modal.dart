class UserData {
  int? id;
  String? username;
  String? email;
  String? role;
  String? status;  // New field for user status

  // Constructor
  UserData({this.id, this.username, this.email, this.role, this.status});

  // Convert JSON to UserData object
  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    status = json['status'];  // Set the status field
  }

  // Convert UserData object to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['status'] = status;  // Include status in the JSON output
    return data;
  }
}
