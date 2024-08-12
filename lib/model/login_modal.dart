

import 'package:allinone_app/model/user_data_modal.dart';

class LoginResponse {
  bool? success;
  UserData? userData;
  String? message;

  LoginResponse({this.success, this.userData, this.message});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    userData = json['data'] != null ? UserData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (userData != null) {
      data['data'] = userData!.toJson();
    }
    data['message'] = message;
    return data;
  }
}


