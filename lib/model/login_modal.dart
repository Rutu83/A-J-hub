import 'package:ajhub_app/model/user_data_modal.dart';

class LoginResponse {
  bool? success;
  String? message;
  String? token;
  UserData? userData;

  LoginResponse({this.success, this.message, this.token, this.userData});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userData: json['user'] != null ? UserData.fromJson(json['user']) : null,
      success: json['status'] == "success",
      message: json['message'],
      token: json['token'],
    );
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
