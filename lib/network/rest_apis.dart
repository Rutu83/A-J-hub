// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;


// login
Future<LoginResponse> loginUser(Map request) async {
  appStore.setLoading(true);

  try {
    log("Request New : $request");
    LoginResponse res = LoginResponse.fromJson(await (handleResponse(
        await buildHttpResponse('login',
            request: request, method: HttpMethodType.POST))));
    return res;
  } catch (e) {

    log("Error during login request: $e");

    rethrow;
  }
}
// save data to shared preferences
Future<void> saveUserDataMobile(LoginResponse loginResponse, UserData data) async {
 if (loginResponse.token.validate().isNotEmpty) await appStore.setToken('');
  await appStore.setToken(loginResponse.token.validate());
  await appStore.setLoggedIn(true);
  await appStore.setName(data.username.validate());
  await appStore.setEmail(data.email.validate());

   appStore.setLoading(false);
  ///Set app configurations
  if (appStore.isLoggedIn) {
    //getAppConfigurations();
  }
}





// Sing up user

Future<void> _registerUser() async {
  const String apiUrl = '${BASE_URL}register';

  final response = await http.post(
    Uri.parse(apiUrl),
    body: jsonEncode({

    }),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
  } else {

  }
}