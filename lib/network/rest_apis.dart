// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/model/categories_mode.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:flutter/foundation.dart';
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
Future<void> updateProfile({
  required String name,
  required String gender,
  required String dob,
  required Function() onSuccess,
  required Function() onFail,
}) async {


  final String authToken = appStore.token;
  const String apiUrl = 'https://ajhub.co.in/api/profile/update';

  final Map<String, dynamic> payload = {
    'username': name,
    'gender': gender,
    'dob': dob,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken", // Fix the token format with Bearer
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print(response.body);
        print('Status Code: ${response.statusCode}');
      }
      onSuccess();
      // _showSnackBar(context, 'Password changed successfully', Colors.green);
      // Navigator.pop(context); // Navigate back after successful password change
    } else {
      // Show error from server response
      String errorMessage = 'DATA change failed';
      if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        errorMessage = responseBody['message'] ?? errorMessage;
      }
      onFail();
      if (kDebugMode) {
        print(errorMessage);
      }
      //   _showSnackBar(context, errorMessage, Colors.red);
      if (kDebugMode) {
        print('Error: ${response.body}');
        print('Status Code: ${response.statusCode}');
      }
    }
  } catch (error) {
    onFail();
    if (kDebugMode) {
      print('Error: $error');
    }

  } finally {

  }
}





// get business-data
Future<List<BusinessModal>> getBusinessData({required List<BusinessModal>? businessmodal}) async {
  try {
    BusinessModal res;

    res = BusinessModal.fromJson(await handleResponse(await buildHttpResponse('business-data', method: HttpMethodType.GET)));
    businessmodal!.clear();
    businessmodal.add(res);
    // lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);
    //
    cachedDashbord = cachedDashbord;

    appStore.setLoading(false);

    return businessmodal;
  } catch (e) {
    appStore.setLoading(false);

    rethrow;
  }
}




// get Categories
Future<CategoriesResponse> getCategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse('getCategories', method: HttpMethodType.GET));
    final res = CategoriesResponse.fromJson(responseJson);

    // If you want to cache the result
    cachedHome = cachedHome ?? []; // Initialize if null
    cachedHome?.clear();
    cachedHome?.add(res);

    appStore.setLoading(false);

    return res; // Return a single CategoriesResponse
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}
