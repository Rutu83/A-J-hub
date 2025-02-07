// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/model/categories_mode.dart';
import 'package:allinone_app/model/categories_subcategories_modal%20.dart';
import 'package:allinone_app/model/daillyuse_modal.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/model/team_model.dart';
import 'package:allinone_app/model/transaction_model.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;



Future<void> clearPreferences() async {
  await appStore.setToken('');
  await appStore.setLoggedIn(false);

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
  await appStore.setStatus(data.status.validate());


  appStore.setLoading(false);
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
Future<void> updateProfile({required String name, required String gender, required String dob, required Function() onSuccess, required Function() onFail,}) async {
  final String authToken = appStore.token;
  const String apiUrl = '${BASE_URL}profile/update';

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
        "Authorization": "Bearer $authToken",
      },
      body: json.encode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      onSuccess();
    } else {
      String errorMessage = 'DATA change failed';
      if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        errorMessage = responseBody['message'] ?? errorMessage;
      }
      onFail();
    }
  } catch (error) {
    onFail();
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
    final responseJson = await handleResponse(await buildHttpResponse('categories', method: HttpMethodType.GET));
    final res = CategoriesResponse.fromJson(responseJson);
    cachedHome = cachedHome ?? [];
    cachedHome?.clear();
    cachedHome?.add(res);

    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }

}


// get sub category
Future<SubcategoryResponse> getSubCategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse('subcategories', method: HttpMethodType.GET));
    final res = SubcategoryResponse.fromJson(responseJson);

    cachedsubcategory = cachedsubcategory ?? [];
    cachedsubcategory?.clear();
    cachedsubcategory?.add(res);

    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}


// Fetch Categories With Subcategories
Future<CategoriesWithSubcategoriesResponse> getCategoriesWithSubcategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse('categories-with-subcategories', method: HttpMethodType.GET));

    final categoriesResponse = CategoriesWithSubcategoriesResponse.fromJson(responseJson);

    cachedcategorywithsubcategory = cachedcategorywithsubcategory ?? [];
    cachedcategorywithsubcategory?.clear();
    cachedcategorywithsubcategory?.add(categoriesResponse);

    appStore.setLoading(false);

    return categoriesResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}




// Fetch and parse data
Future<DaillyuseResponse> getDailyUseWithSubcategory() async {
  try {
    final responseJson = await handleResponse(
        await buildHttpResponse('getdailyusewithsubcategory', method: HttpMethodType.GET));

    final res = DaillyuseResponse.fromJson(responseJson as List<dynamic>);
    cacheddaillyusecategory = cacheddaillyusecategory ?? [];
    cacheddaillyusecategory?.clear();
    cacheddaillyusecategory?.add(res);

    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}



// get Team-data
Future<List<TeamModel>> getTeamData({required List<TeamModel>? teammodal}) async {
  try {
    TeamModel res;

    res = TeamModel.fromJson(await handleResponse(await buildHttpResponse('users-without-transactions', method: HttpMethodType.GET)));
    teammodal!.clear();
    teammodal.add(res);
    cachedTeam = cachedTeam;

    appStore.setLoading(false);

    return teammodal;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}


// get Team-data
Future<List<TransactionResponse>> getTransactionData({required List<TransactionResponse>? transactionmodal}) async {
  try {
    TransactionResponse res;
    res = TransactionResponse.fromJson(await handleResponse(await buildHttpResponse('user-wallet-transactions', method: HttpMethodType.GET)));
    transactionmodal!.clear();
    transactionmodal.add(res);
    // lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);
    cachedTransaction = cachedTransaction;
    appStore.setLoading(false);
    return transactionmodal;
  } catch (e) {
    appStore.setLoading(false);

    rethrow;
  }
}



Future<void> fetchData(Function(List<Map<String, dynamic>>) updateProducts, Function(String) updateData) async {
  const String url = "${BASE_URL}inquiries/active";
  String token = appStore.token;
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      updateProducts(List<Map<String, dynamic>>.from(jsonData));
    } else {

      updateData("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    updateData("An error occurred: $e");
  }
}
