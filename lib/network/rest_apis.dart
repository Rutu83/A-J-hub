// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/model/categories_mode.dart';
import 'package:ajhub_app/model/categories_subcategories_modal%20.dart';
import 'package:ajhub_app/model/daillyuse_modal.dart';
import 'package:ajhub_app/model/devotation_model.dart';
import 'package:ajhub_app/model/login_modal.dart';
import 'package:ajhub_app/model/plan_model.dart';
import 'package:ajhub_app/model/subscription_plan_model.dart'; // NEW: Subscription Plan Model
import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/model/team_model.dart';
import 'package:ajhub_app/model/temple_model.dart';
import 'package:ajhub_app/model/transaction_model.dart';
import 'package:ajhub_app/model/upcoming_model.dart';
import 'package:ajhub_app/model/user_data_modal.dart';
import 'package:ajhub_app/network/network_utils.dart';
import 'package:ajhub_app/network/notification_service.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

//
// Future<void> clearPreferences() async {
//   await appStore.setToken('');
//   await appStore.setLoggedIn(false);
//   // if (isAndroid) await OneSignal.shared.clearOneSignalNotifications();
// }

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
Future<void> saveUserDataMobile(
    LoginResponse loginResponse, UserData data) async {
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
Future<void> updateProfile({
  required String name,
  required String gender,
  required String dob,
  required Function() onSuccess,
  required Function() onFail,
}) async {
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
  } finally {}
}

Future<void> submitFranchiseInquiry({
  required String franchiseType,
  required Function(String message) onSuccess,
  required Function(String message) onFail,
}) async {
  // 1. Get token from your central store (e.g., appStore)
  final String? authToken = appStore.token;
  const String apiUrl = '${BASE_URL}franchise-inquiry';

  if (authToken == null || authToken.isEmpty) {
    onFail('Authentication error. Please log in again.');
    return;
  }

  // 2. Define the payload
  final Map<String, dynamic> payload = {
    'franchise_type': franchiseType,
  };

  try {
    // 3. Make the API call
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: json.encode(payload),
    );

    final responseBody = json.decode(response.body);
    final String message =
        responseBody['message'] ?? 'An unknown error occurred.';

    // 4. Handle response using callbacks
    if (response.statusCode == 201) {
      // 201 Created
      onSuccess(message);
    } else {
      // Handle other API errors (401, 409, 422, etc.)
      onFail(message);
    }
  } catch (error) {
    // Handle network exceptions
    onFail('Failed to connect to the server. Please check your network.');
  }
}

// get business-data
Future<List<BusinessModal>> getBusinessData(
    {required List<BusinessModal>? businessmodal}) async {
  if (cachedDashbord != null && cachedDashbord!.isNotEmpty) {
    businessmodal!.clear();
    businessmodal.addAll(cachedDashbord!);
    return businessmodal;
  }

  try {
    BusinessModal res = BusinessModal.fromJson(await handleResponse(
        await buildHttpResponse('business-data', method: HttpMethodType.GET)));

    // --- LOG FOR VERIFICATION ---
    log("Business Data API Response: ${jsonEncode(res.toJson())}");
    businessmodal!.clear();
    businessmodal.add(res);
    cachedDashbord = [];
    cachedDashbord!.add(res);

    appStore.setLoading(false);

    return businessmodal;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// get Categories
Future<CategoriesResponse> getCategories() async {
  if (cachedHome != null && cachedHome!.isNotEmpty) {
    return cachedHome!.first;
  }
  try {
    final responseJson = await handleResponse(
        await buildHttpResponse('categories', method: HttpMethodType.GET));
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

Future<List<Temple>> fetchTemples() async {
  if (cachedTemples != null && cachedTemples!.isNotEmpty) {
    return cachedTemples!;
  }
  final url = Uri.parse('https://ajhub.co.in/api/temples');

  try {
    final response = await http.get(url);

    // Print for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the JSON response into a Map.
      final dynamic decodedBody = jsonDecode(response.body);

      // --- ROBUST HANDLING ---
      // 1. Check if the decoded body is a Map and contains the 'data' key.
      if (decodedBody is Map<String, dynamic> &&
          decodedBody.containsKey('data')) {
        // 2. Safely access the 'data' key, which should be a List.
        final List<dynamic> templeListJson = decodedBody['data'];

        // 3. Map the list of JSON objects to a list of Temple objects.
        // The Temple.fromJson factory will handle any nulls inside each object.
        final temples =
            templeListJson.map((json) => Temple.fromJson(json)).toList();
        cachedTemples = temples;
        return temples;
      } else {
        // The JSON structure was not what we expected.
        throw Exception('Invalid data format received from the server.');
      }
    } else {
      // Handle server-side errors (e.g., 404, 500).
      throw Exception(
          'Failed to load temples. Server responded with status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network errors (e.g., no internet) or parsing errors.
    print('Error in fetchTemples: $e');
    throw Exception(
        'Failed to fetch data. Please check your network connection.');
  }
}

Future<List<NotificationModel>> fetchNotification() async {
  if (cachedNotifications != null && cachedNotifications!.isNotEmpty) {
    return cachedNotifications!;
  }
  final url = Uri.parse('https://ajhub.co.in/api/notifications');

  try {
    final response = await http.get(url);

    // Print for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the JSON response into a Map.
      final dynamic decodedBody = jsonDecode(response.body);

      // --- ROBUST HANDLING ---
      // 1. Check if the decoded body is a Map and contains the 'data' key.
      if (decodedBody is Map<String, dynamic> &&
          decodedBody.containsKey('data')) {
        // 2. Safely access the 'data' key, which should be a List.
        final List<dynamic> templeListJson = decodedBody['data'];

        // 3. Map the list of JSON objects to a list of Temple objects.
        // The Temple.fromJson factory will handle any nulls inside each object.
        final notifications = templeListJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        cachedNotifications = notifications;
        return notifications;
      } else {
        // The JSON structure was not what we expected.
        throw Exception('Invalid data format received from the server.');
      }
    } else {
      // Handle server-side errors (e.g., 404, 500).
      throw Exception(
          'Failed to load temples. Server responded with status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network errors (e.g., no internet) or parsing errors.
    print('Error in fetchTemples: $e');
    throw Exception(
        'Failed to fetch data. Please check your network connection.');
  }
}

// New function to fetch subcategories from the 'upcoming' endpoint
Future<UpcomingSubcategoryResponse> getUpcomingSubcategories(
    {int limit = 10}) async {
  if (cachedUpcomingSubcategory != null &&
      cachedUpcomingSubcategory!.isNotEmpty) {
    return cachedUpcomingSubcategory!.first;
  }
  try {
    final responseJson = await handleResponse(
      // 1. CHANGE: Call the new 'subcategories/upcoming' endpoint
      await buildHttpResponse('subcategories/upcoming',
          method: HttpMethodType.GET),
    );

    final parsedResponse = UpcomingSubcategoryResponse.fromJson(responseJson);

    // Limit the number of items shown on the client side
    final limitedSubcategories =
        parsedResponse.subcategories.take(limit).toList();

    final limitedResponse = UpcomingSubcategoryResponse(
      status: parsedResponse.status,
      subcategories: limitedSubcategories,
    );

    // 2. CHANGE: Use the new cache variable
    cachedUpcomingSubcategory = cachedUpcomingSubcategory ?? [];
    cachedUpcomingSubcategory?.clear();
    cachedUpcomingSubcategory?.add(limitedResponse);

    appStore.setLoading(false);

    return limitedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

Future<SubcategoryResponse> getTrendingSubcategories({int limit = 7}) async {
  // Use a different cache to avoid conflicts
  if (cachedTrendingSubcategory != null &&
      cachedTrendingSubcategory!.isNotEmpty) {
    return cachedTrendingSubcategory!.first;
  }

  try {
    // Show loading indicator
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // 1. CHANGE: Call the new 'subcategories/trending' endpoint
      await buildHttpResponse('subcategories/trending',
          method: HttpMethodType.GET),
    );

    final parsedResponse = SubcategoryResponse.fromJson(responseJson);

    // Limit the number of items shown on the client side
    final limitedSubcategories =
        parsedResponse.subcategories.take(limit).toList();

    final limitedResponse = SubcategoryResponse(
      status: parsedResponse.status,
      subcategories: limitedSubcategories,
    );

    // 2. CHANGE: Use the new cache variable
    cachedTrendingSubcategory = cachedTrendingSubcategory ?? [];
    cachedTrendingSubcategory?.clear();
    cachedTrendingSubcategory?.add(limitedResponse);

    appStore.setLoading(false);
    return limitedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

Future<SubcategoryResponse> fetchZoomBgCategories() async {
  // Use a different cache to avoid conflicts
  // if (cachedTrendingSubcategory != null) return cachedTrendingSubcategory!.first;

  try {
    // Show loading indicator
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // 1. CHANGE: Call the new 'subcategories/trending' endpoint
      await buildHttpResponse('subcategories/zoombg',
          method: HttpMethodType.GET),
    );

    final parsedResponse = SubcategoryResponse.fromJson(responseJson);

    // Limit the number of items shown on the client side
    final limitedSubcategories = parsedResponse.subcategories.toList();

    final limitedResponse = SubcategoryResponse(
      status: parsedResponse.status,
      subcategories: limitedSubcategories,
    );

    // 2. CHANGE: Use the new cache variable
    cachedTrendingSubcategory = cachedTrendingSubcategory ?? [];
    cachedTrendingSubcategory?.clear();
    cachedTrendingSubcategory?.add(limitedResponse);

    appStore.setLoading(false);
    return limitedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// get sub category
Future<SubcategoryResponse> getSubCategories({int limit = 7}) async {
  if (cachedsubcategory != null && cachedsubcategory!.isNotEmpty) {
    return cachedsubcategory!.first;
  }
  try {
    final responseJson = await handleResponse(
      await buildHttpResponse('subcategories', method: HttpMethodType.GET),
    );

    final parsedResponse = SubcategoryResponse.fromJson(responseJson);

    // Limit to only 5 subcategories
    final limitedSubcategories =
        parsedResponse.subcategories.take(limit).toList();

    final limitedResponse = SubcategoryResponse(
      status: parsedResponse.status,
      subcategories: limitedSubcategories,
    );

    cachedsubcategory = cachedsubcategory ?? [];
    cachedsubcategory?.clear();
    cachedsubcategory?.add(limitedResponse);

    appStore.setLoading(false);

    return limitedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

Future<SubcategoryResponse> getAllSubCategories({int page = 1}) async {
  try {
    final responseJson = await handleResponse(
      await buildHttpResponse('subcategories?page=$page',
          method: HttpMethodType.GET),
    );

    final parsedResponse = SubcategoryResponse.fromJson(responseJson);

    // Limit to only 5 subcategories
    final limitedSubcategories = parsedResponse.subcategories.toList();

    final limitedResponse = SubcategoryResponse(
      status: parsedResponse.status,
      subcategories: limitedSubcategories,
    );

    cachedsubcategory = cachedsubcategory ?? [];
    cachedsubcategory?.clear();
    cachedsubcategory?.add(limitedResponse);

    appStore.setLoading(false);

    return limitedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// Fetch Categories With Subcategories
Future<CategoriesWithSubcategoriesResponse>
    getCategoriesWithSubcategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse(
        'categories-with-subcategories',
        method: HttpMethodType.GET));

    final categoriesResponse =
        CategoriesWithSubcategoriesResponse.fromJson(responseJson);

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
  if (cacheddaillyusecategory != null && cacheddaillyusecategory!.isNotEmpty) {
    return cacheddaillyusecategory!.first;
  }
  try {
    final responseJson = await handleResponse(await buildHttpResponse(
        'getdailyusewithsubcategory',
        method: HttpMethodType.GET));

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

// Fetch and parse data
Future<DevotationuseResponse> getDevotationUseWithSubcategory() async {
  if (cacheddDevotionalusecategory != null &&
      cacheddDevotionalusecategory!.isNotEmpty) {
    return cacheddDevotionalusecategory!.first;
  }
  try {
    final responseJson = await handleResponse(await buildHttpResponse(
        'getdevotionalsubcategory',
        method: HttpMethodType.GET));

    final res = DevotationuseResponse.fromJson(responseJson as List<dynamic>);
    cacheddDevotionalusecategory = cacheddDevotionalusecategory ?? [];
    cacheddDevotionalusecategory?.clear();
    cacheddDevotionalusecategory?.add(res);

    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// Fetch and parse data
Future<DaillyuseResponse> getdirectsellingUseWithSubcategory() async {
  if (cachedDirectSellingSubcategory != null &&
      cachedDirectSellingSubcategory!.isNotEmpty) {
    return cachedDirectSellingSubcategory!.first;
  }
  try {
    final responseJson = await handleResponse(await buildHttpResponse(
        'getdirectsellingsubcategory',
        method: HttpMethodType.GET));

    final res = DaillyuseResponse.fromJson(responseJson as List<dynamic>);
    cachedDirectSellingSubcategory = cachedDirectSellingSubcategory ?? [];
    cachedDirectSellingSubcategory?.clear();
    cachedDirectSellingSubcategory?.add(res);

    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// get Team-data
Future<List<TeamModel>> getTeamData(
    {required List<TeamModel>? teammodal}) async {
  try {
    TeamModel res;

    res = TeamModel.fromJson(await handleResponse(await buildHttpResponse(
        'users-without-transactions',
        method: HttpMethodType.GET)));
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
Future<List<TransactionResponse>> getTransactionData(
    {required List<TransactionResponse>? transactionmodal}) async {
  try {
    TransactionResponse res;
    res = TransactionResponse.fromJson(await handleResponse(
        await buildHttpResponse('user-wallet-transactions',
            method: HttpMethodType.GET)));
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

Future<void> fetchData(Function(List<Map<String, dynamic>>) updateProducts,
    Function(String) updateData) async {
  const String url = "${BASE_URL}inquiries/active";
  String token = appStore.token;

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 10)); // Added timeout condition
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      updateProducts(List<Map<String, dynamic>>.from(jsonData));
    } else {
      updateData("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } on SocketException {
    updateData("No internet connection. Please check your network.");
  } on HttpException {
    updateData("Couldn't connect to the server. Try again later.");
  } on TimeoutException {
    updateData("Network timeout. Please try again.");
  } catch (e) {
    updateData("An unexpected error occurred: $e");
  }
}

Future<List<UserPlan>> getPlans({String? date, String? month}) async {
  // We remove appStore.setLoading here because the UI's FutureBuilder handles it.
  // appStore.setLoading(true);

  try {
    final String? authToken = appStore.token;
    if (authToken == null || authToken.isEmpty) {
      throw Exception('Authentication error: Token is missing.');
    }

    String endpoint = 'plans';
    if (date != null) {
      endpoint += '?date=$date';
    } else if (month != null) {
      // The API will expect a format like '2024-08'
      endpoint += '?month=$month';
    }
    final String apiUrl = '$BASE_URL$endpoint';

    // --- DEBUG STEP 1: PRINT THE REQUEST ---
    print('--- 🚀 [GET] SENDING TO API 🚀 ---');
    print('URL: $apiUrl');
    print(
        'Auth Token: Bearer ${authToken.substring(0, 10)}...'); // Print first 10 chars
    print('--------------------------');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );

    // --- DEBUG STEP 2: PRINT THE RESPONSE ---
    print('--- 👽 [GET] RECEIVED FROM API 👽 ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('-----------------------------');

    if (response.statusCode == 200) {
      // If the body is empty, return an empty list.
      if (response.body.isEmpty || response.body == "[]") {
        return [];
      }
      return userPlanFromJson(response.body);
    } else {
      // Throw a specific error based on the status code
      throw Exception(
          'Failed to load plans. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // --- DEBUG STEP 3: PRINT ANY PARSING OR NETWORK ERRORS ---
    print('--- 💥 [GET] API CALL FAILED 💥 ---');
    print('Error Type: ${error.runtimeType}');
    print('Error: $error');
    print('---------------------------');
    rethrow; // Re-throw the error so the FutureBuilder can catch it.
  } finally {
    // appStore.setLoading(false);
  }
}

// Fetch Subscription Plans
Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
  try {
    // appStore.setLoading(true); // Handled by FutureBuilder usually
    final String apiUrl = '${BASE_URL}subscription-plans'; // Using new endpoint

    print('--- 🚀 [GET] Subscription Plans 🚀 ---');
    print('URL: $apiUrl');
    print('--------------------------------------');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Accept": "application/json",
        // "Authorization": "Bearer ${appStore.token}", // Optional depending on API
      },
    );

    print('--- 👽 [GET] Response 👽 ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('-----------------------------');

    if (response.statusCode == 200) {
      return subscriptionPlanFromJson(response.body);
    } else {
      throw Exception('Failed to load plans: ${response.statusCode}');
    }
  } catch (e) {
    print('--- 💥 [GET] Failed to load plans 💥 ---');
    print('Error: $e');
    rethrow;
  }
}

// Fetch Airpay Merchant Credentials
Future<Map<String, dynamic>> initiateAirpayPayment({
  required String paymentId,
  required int planId,
  required String period,
}) async {
  try {
    final String apiUrl = '${BASE_URL}airpay/initiate';
    print('--- 🚀 [POST] Initiate Airpay 🚀 ---');
    print('URL: $apiUrl');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        // Authorization header might be needed if the endpoint is protected
        if (appStore.token.isNotEmpty)
          "Authorization": "Bearer ${appStore.token}",
      },
      body: jsonEncode({
        'payment_id': paymentId,
        'plan_id': planId,
        'period': period,
      }),
    );

    print('--- 👽 [POST] Response 👽 ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('-----------------------------');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      print(
          '>>> [DEBUG] Airpay Credentials: $body'); // Log for user verification
      if (body is Map<String, dynamic>) {
        return body;
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to initiate payment: ${response.statusCode}');
    }
  } catch (e) {
    print('--- 💥 [POST] Failed to initiate payment 💥 ---');
    print('Error: $e');
    rethrow;
  }
}

// PUT /api/plans/{id}
Future<void> updatePlanStatus(int planId, bool isCompleted) async {
  try {
    final String? authToken = appStore.token;
    if (authToken == null || authToken.isEmpty) return;

    final String apiUrl = '${BASE_URL}plans/$planId';
    final payload = {'is_completed': isCompleted};

    await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: json.encode(payload),
    );
    // We don't need to handle success/fail messages here, UI will handle it
  } catch (e) {
    // Optional: log error
    print("Failed to update plan status: $e");
  }
}

// DELETE /api/plans/{id}
Future<bool> deletePlan(int planId) async {
  try {
    final String? authToken = appStore.token;
    if (authToken == null || authToken.isEmpty) return false;

    final String apiUrl = '${BASE_URL}plans/$planId';
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
    );
    print('response ${response.body}');
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> createPlan({
  required Map<String, dynamic> payload,
  required Function(String message) onSuccess,
  required Function(String message) onFail,
}) async {
  appStore.setLoading(true);

  try {
    final String? authToken = appStore.token;
    if (authToken == null || authToken.isEmpty) {
      onFail('Authentication error. Please log in again.');
      appStore.setLoading(false);
      return;
    }

    const String apiUrl = '${BASE_URL}plans';

    // --- DEBUG STEP 1: PRINT THE DATA YOU ARE ABOUT TO SEND ---
    print('--- 🚀 SENDING TO API 🚀 ---');
    print('URL: $apiUrl');
    print('Payload: ${json.encode(payload)}');
    print('--------------------------');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: json.encode(payload),
    );

    // --- DEBUG STEP 2: PRINT THE RESPONSE YOU GOT BACK ---
    print('--- 👽 RECEIVED FROM API 👽 ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('-----------------------------');

    final responseBody = json.decode(response.body);
    final String message =
        responseBody['message'] ?? 'An unknown error occurred.';

    if (response.statusCode == 201) {
      onSuccess(message);
    } else {
      final errors = responseBody['errors'];
      String errorMessage = message;
      if (errors != null && errors is Map) {
        errorMessage = errors.entries.first.value[0];
      }
      onFail(errorMessage);
    }
  } catch (error) {
    // --- DEBUG STEP 3: PRINT ANY UNEXPECTED EXCEPTIONS ---
    print('--- 💥 API CALL FAILED 💥 ---');
    print('Error Type: ${error.runtimeType}');
    print('Error: $error');
    print('---------------------------');
    onFail('Failed to connect to the server. Please check your network.');
  } finally {
    appStore.setLoading(false);
  }
}

Future<UpcomingSubcategoryResponse> getAgricultureSubcategories() async {
  // Check cache first
  if (cachedAgricultureSubcategory != null &&
      cachedAgricultureSubcategory!.isNotEmpty) {
    return cachedAgricultureSubcategory!.first;
  }

  try {
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // NOTE: Assumed endpoint. Change 'agriculture' if it's different.
      await buildHttpResponse('getAgricultureSubcategories',
          method: HttpMethodType.GET),
    );

    final parsedResponse = UpcomingSubcategoryResponse.fromJson(responseJson);

    // Initialize, clear, and update the cache
    cachedAgricultureSubcategory = cachedAgricultureSubcategory ?? [];
    cachedAgricultureSubcategory!.clear();
    cachedAgricultureSubcategory!.add(parsedResponse);

    appStore.setLoading(false);
    return parsedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow; // Rethrow the error to be handled by the UI
  }
}

// 2. For Entrepreneurs Section
Future<UpcomingSubcategoryResponse> getEntrepreneursSubcategories() async {
  // Check cache first
  if (cachedEntrepreneursSubcategory != null &&
      cachedEntrepreneursSubcategory!.isNotEmpty) {
    return cachedEntrepreneursSubcategory!.first;
  }

  try {
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // NOTE: Assumed endpoint. Change 'entrepreneurs' if it's different.
      await buildHttpResponse('getEntrepreneursSubcategories',
          method: HttpMethodType.GET),
    );

    final parsedResponse = UpcomingSubcategoryResponse.fromJson(responseJson);

    // Initialize, clear, and update the cache
    cachedEntrepreneursSubcategory = cachedEntrepreneursSubcategory ?? [];
    cachedEntrepreneursSubcategory!.clear();
    cachedEntrepreneursSubcategory!.add(parsedResponse);

    appStore.setLoading(false);
    return parsedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// 3. For Temple Of India Section
Future<UpcomingSubcategoryResponse> getTempleOfIndiaSubcategories() async {
  // Check cache first
  if (cachedTempleOfIndiaSubcategory != null &&
      cachedTempleOfIndiaSubcategory!.isNotEmpty) {
    return cachedTempleOfIndiaSubcategory!.first;
  }

  try {
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // NOTE: Assumed endpoint. A good practice for multi-word endpoints is using hyphens.
      await buildHttpResponse('getTempleOfIndiaSubcategories',
          method: HttpMethodType.GET),
    );

    final parsedResponse = UpcomingSubcategoryResponse.fromJson(responseJson);

    // Initialize, clear, and update the cache
    cachedTempleOfIndiaSubcategory = cachedTempleOfIndiaSubcategory ?? [];
    cachedTempleOfIndiaSubcategory!.clear();
    cachedTempleOfIndiaSubcategory!.add(parsedResponse);

    appStore.setLoading(false);
    return parsedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}

// 4. For Celebrate The Movement Section
Future<UpcomingSubcategoryResponse>
    getCelebrateTheMovementSubcategories() async {
  // Check cache first
  if (cachedCelebrateTheMovementSubcategory != null &&
      cachedCelebrateTheMovementSubcategory!.isNotEmpty) {
    return cachedCelebrateTheMovementSubcategory!.first;
  }

  try {
    appStore.setLoading(true);

    final responseJson = await handleResponse(
      // NOTE: Assumed endpoint. Change if necessary.
      await buildHttpResponse('getCelebrateTheMovementSubcategories',
          method: HttpMethodType.GET),
    );

    final parsedResponse = UpcomingSubcategoryResponse.fromJson(responseJson);

    // Initialize, clear, and update the cache
    cachedCelebrateTheMovementSubcategory =
        cachedCelebrateTheMovementSubcategory ?? [];
    cachedCelebrateTheMovementSubcategory!.clear();
    cachedCelebrateTheMovementSubcategory!.add(parsedResponse);

    appStore.setLoading(false);
    return parsedResponse;
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}
