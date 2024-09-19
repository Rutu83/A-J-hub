// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;



Future<void> clearPreferences() async {

  await appStore.setToken('');
  await appStore.setLoggedIn(false);


  // TODO: Please do not remove this condition because this feature not supported on iOS.
  // if (isAndroid) await OneSignal.shared.clearOneSignalNotifications();
}










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
 appStore.setToken(loginResponse.token!);
  await appStore.setLoggedIn(true);
  await appStore.setName(data.username.validate());
  await appStore.setEmail(data.email.validate());

   appStore.setLoading(false);
  ///Set app configurations
  if (appStore.isLoggedIn) {
    //getAppConfigurations();
  }
}


// get user profile
Future<Map<String, dynamic>> getUserDetail() async {
  try {
    Map<String, dynamic> res;

    res = await handleResponse(
        await buildHttpResponse('profile', method: HttpMethodType.GET));
    return res['profile'];
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// update profile
Future<void> updateUserData(userIdn, {required String name, required String email, required String number, required String shopName, required String country, required String state, required String city, required String pincode, required String address, required onSuccess,required Null Function() onSuccesss,required onFail,required Null Function() onFaild}) async {
  final token = appStore.token;
  var userId = userIdn;
  final url = Uri.parse('${BASE_URL}vendor/edit/$userId');
  final userData = {
    'name': name,
    'email': email,
    'number':number,
    'country': country,
    'state': state,
    'city': city,
    'pincode': pincode,
    'address': address,
  };

  try {
    final response = await http.put(
      url,
      body: jsonEncode(userData),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: token,
      },
    );

    if (response.statusCode == 200) {


      onSuccess();
      onSuccesss();
    } else {
      onFail();
      onFaild();

    }
  } catch (e) {
    onFail();
    onFaild();

  }
}


// get business-data
Future<Map<String, dynamic>> getBusinessDetail() async {
  try {
    Map<String, dynamic>? res;

    // Check if the response is not null
    res = await handleResponse(
        await buildHttpResponse('business-data', method: HttpMethodType.GET));

    // Handle the case where 'Response' is null or the expected structure isn't present
    if (res == null || res['Response'] == null) {
      throw Exception("Invalid or null response from API");
    }

    return res['Response'] as Map<String, dynamic>;
  } catch (e) {
    appStore.setLoading(false);
    print('Error in getBusinessDetail: $e');
    rethrow;  // Still rethrowing so the caller can handle the error
  }
}










