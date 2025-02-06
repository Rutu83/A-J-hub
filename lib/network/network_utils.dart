import 'dart:convert';
import 'dart:io';
import 'package:allinone_app/arth_screens/login_screen.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/utils/common.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:allinone_app/main.dart';
import 'package:allinone_app/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

Map<String, String> buildHeaderTokens({
  Map? extraKeys,
}) {
  /// Initialize & Handle if key is not present
  if (extraKeys == null) {
    extraKeys = {};
    extraKeys.putIfAbsent('isStripePayment', () => false);
    extraKeys.putIfAbsent('isFlutterWave', () => false);
    extraKeys.putIfAbsent('isSadadPayment', () => false);
  }

  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (appStore.isLoggedIn &&
      extraKeys.containsKey('isStripePayment') &&
      extraKeys['isStripePayment']) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader,
            () => 'application/x-www-form-urlencoded');
    header.putIfAbsent(HttpHeaders.authorizationHeader,
            () => '${extraKeys!['stripeKeyPayment']}');
  } else if (appStore.isLoggedIn &&
      extraKeys.containsKey('isFlutterWave') &&
      extraKeys['isFlutterWave']) {
    header.putIfAbsent(HttpHeaders.authorizationHeader,
            () => "Bearer ${extraKeys!['flutterWaveSecretKey']}");
  } else if (appStore.isLoggedIn &&
      extraKeys.containsKey('isSadadPayment') &&
      extraKeys['isSadadPayment']) {
    header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json');
    if (extraKeys['sadadToken'].validate().isNotEmpty) {
      header.putIfAbsent(
          HttpHeaders.authorizationHeader, () => extraKeys!['sadadToken']);
    }
  } else {
    header.putIfAbsent(
        HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
    header.putIfAbsent(
        HttpHeaders.authorizationHeader, () =>'Bearer ${appStore.token}');
    header.putIfAbsent(
        HttpHeaders.acceptHeader, () => 'application/json; charset=utf-8');
  }

  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$BASE_URL$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<String> refreshToken() async {
  final refreshToken = appStore.token;
  final response = await http.post(
    Uri.parse('https://yourapi.com/auth/refresh'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'refresh_token': refreshToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    appStore.token = data['access_token'];
    return data['access_token'];
  } else {
    throw Exception('Failed to refresh token');
  }
}



Future<http.Response> buildHttpResponse(
    String endPoint, {
      HttpMethodType method = HttpMethodType.GET,
      Map? request,
      Map? extraKeys,
    }) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(extraKeys: extraKeys);
    Uri url = buildBaseUrl(endPoint);

    http.Response response;

    if (method == HttpMethodType.POST) {
      log('Request: ${jsonEncode(request)}');
      response =
      await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethodType.DELETE) {
      response = await http.delete(url, headers: headers);
    } else if (method == HttpMethodType.PUT) {
      response = await http.put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await http.get(url, headers: headers);
    }

    log('Response (${method.name}) ${response.statusCode}: ${response.body}');
    //apiPrint(url: url.toString(),endPoint: endPoint, headers: jsonEncode(headers),hasRequest: method == HttpMethodType.POST || method == HttpMethodType.PUT, request: jsonEncode(request), statusCode: response.statusCode, responseBody: response.body, methodtype: method.name);
    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

Future handleResponse(http.Response response,
    {HttpResponseType httpResponseType = HttpResponseType.JSON,
      bool? avoidTokenError,
      bool? isSadadPayment}) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  if (response.statusCode == 401) {
    redirectToLogin();
    if (!avoidTokenError.validate()) LiveStream().emit(TOKEN, true);

    throw language.lblTokenExpired;
  } else if (response.statusCode == 400) {
    throw language.badRequest;
  } else if (response.statusCode == 403) {

    throw language.forbidden;
  } else if (response.statusCode == 404) {

    throw language.pageNotFound;
  } else if (response.statusCode == 429) {

    throw language.tooManyRequests;
  } else if (response.statusCode == 500) {
    redirectToLogin();
    throw language.internalServerError;

  } else if (response.statusCode == 502) {

    throw language.badGateway;
  } else if (response.statusCode == 503) {

    throw language.serviceUnavailable;
  } else if (response.statusCode == 504) {
    throw language.gatewayTimeout;
  }

  if (response.statusCode.isSuccessful() || response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    if (isSadadPayment.validate()) {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['error']['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    } else {
      try {
        var body = jsonDecode(response.body);
        throw parseHtmlString(body['message']);
      } on Exception catch (e) {
        log(e);
        throw errorSomethingWentWrong;
      }
    }
  }
}
void redirectToLogin() async{
  var pref = await SharedPreferences.getInstance();
  // var pref = await SharedPreferences.getInstance();

  await pref.remove(SplashScreenState.keyLogin);
  await pref.remove(TOKEN);
  await pref.remove(ROLE);
  await pref.remove(VENDOR_TYPE);
  await pref.remove(NUMBER);
  await appStore.setToken('', isInitializing: true);
  await appStore.setNumber('', isInitializing: true);

  appStore.setLoading(false);

  await navigatorKeyNew.currentState!.push(
    MaterialPageRoute(builder: (context) => const LoginScreen()),
  );
}


Future<http.Response> makeAuthenticatedRequest(
    String endPoint, {
      HttpMethodType method = HttpMethodType.GET,
      Map? request,
      Map? extraKeys,
    }) async {
  try {
    return await buildHttpResponse(endPoint, method: method, request: request, extraKeys: extraKeys);
  } on Exception catch (e) {
    if (e.toString().contains('jwt expired')) {
      await refreshToken();
      return await buildHttpResponse(endPoint, method: method, request: request, extraKeys: extraKeys);
    } else {
      rethrow;
    }
  }
}


Future<http.MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = baseUrl ?? buildBaseUrl(endPoint).toString();
  return http.MultipartRequest('POST', Uri.parse(url));
}

String parseStripeError(String response) {
  try {
    var body = jsonDecode(response);
    return parseHtmlString(body['error']['message']);
  } on Exception catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}

void apiPrint({
  String url = "",
  String endPoint = "",
  String headers = "",
  String request = "",
  int statusCode = 0,
  String responseBody = "",
  String methodtype = "",
  bool hasRequest = false,
}) {
  log("┌───────────────────────────────────────────────────────────────────────────────────────────────────────");
  log("\u001b[93m Url: \u001B[39m $url");
  log("\u001b[93m Header: \u001B[39m \u001b[96m$headers\u001B[39m");
  log("\u001b[93m Request: \u001B[39m \u001b[96m$request\u001B[39m");
  log(statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m");
  log('Response ($methodtype) $statusCode: $responseBody');
  log("\u001B[0m");
  log("└───────────────────────────────────────────────────────────────────────────────────────────────────────");
}
