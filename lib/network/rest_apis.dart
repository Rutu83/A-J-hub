import 'dart:async';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:nb_utils/nb_utils.dart';



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

Future<void> saveUserDataMobile(LoginResponse loginResponse, UserData data) async {
 if (data.token.validate().isNotEmpty) await appStore.setToken('');
  await appStore.setToken(data.token.validate());
  await appStore.setLoggedIn(true);
  await appStore.setName(data.name.validate());
   appStore.setLoading(false);
  ///Set app configurations
  if (appStore.isLoggedIn) {
    //getAppConfigurations();
  }
}

