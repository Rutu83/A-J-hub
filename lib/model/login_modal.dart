import 'package:ajhub_app/model/user_data_modal.dart';

class LoginResponse {
  bool? success;
  String? message;
  String? token;
  UserData? userData;

  LoginResponse({this.success, this.message, this.token, this.userData});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['status'] == "success";
    message = json['message'];
    token = json['token'];
    userData = json['user'] != null ? UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = success == true ? "success" : "failure";
    data['message'] = message;
    data['token'] = token;
    if (userData != null) {
      data['user'] = userData!.toJson();
    }
    return data;
  }
}
