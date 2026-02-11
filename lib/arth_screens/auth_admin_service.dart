import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/login_modal.dart';
import 'package:ajhub_app/model/user_data_modal.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Future<LoginResponse> loginCurrentAdminMobile(BuildContext context,
    {required Map<String, String> req,
    bool isSocialLogin = false,
    bool isOtpLogin = false}) async {
  appStore.setLoading(true);
  final userValue = await loginUser(req);
  log("***************** Normal Login $userValue *****************");
  log("***************** Normal Login Succeeds *****************");

  return userValue;
}

void saveDataToAdminPreferenceMobile(BuildContext context,
    {required LoginResponse loginResponse,
    required UserData parentUserData,
    bool isSocialLogin = false,
    required Function onRedirectionClick}) async {
  try {
    log("***************** Normal registration join1 *****************");

    log("***************** Normal registration join 2*****************");
    await saveUserDataMobile(loginResponse, parentUserData);
    log("***************** Normal registration join 3*****************");
    onRedirectionClick.call();
  } catch (e) {
    log("Error saving data to preferences: $e");
  }
}

saveDataToregisterPreferenceMobile(context,
    {required LoginResponse loginResponse,
    required UserData parentUserData,
    bool isSocialLogin = false,
    required Function onRedirectionClick}) async {
  try {
    log("***************** Normal registration join1 *****************");

    log("***************** Normal registration join 2*****************");
    await saveUserDataMobile(loginResponse, parentUserData);
    log("***************** Normal registration join 3*****************");
    onRedirectionClick.call();
  } catch (e) {
    log("Error saving data to preferences: $e");
  }
}
