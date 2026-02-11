class UserData {
  int? id;
  String? username;
  String? email;
  String? role;
  String? status;

  // Constructor
  UserData({this.id, this.username, this.email, this.role, this.status});




  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        id : json['id'],
        username : json['username'],
        email : json['email'],
    role : json['role'],
    status : json['status'],
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) data['id'] = this.id;
    if (this.username != null) data['username'] = this.username;
    if (this.email != null) data['email'] = this.email;
    if (this.role != null) data['role'] = this.role;
    if (this.status != null) data['status'] = this.status;

    return data;
  }
}
