class UserData {
  String? token;
  String? name;

  UserData({this.token, this.name});

  UserData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (token != null) data['token'] = token;
    if (name != null) data['name'] = name;
  //  data['token'] = this.token;
   // data['name'] = this.name;
    return data;
  }
}