

// ignore_for_file: non_constant_identifier_names

import 'package:ajhub_app/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'app_store.g.dart';


// ignore: library_private_types_in_public_api
class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {

  @observable
  String token = '';

  @observable
  bool isLoggedIn = false;

  @observable
  int countryId = 0;

  @observable
  String loginType = '';

  @observable
  String userEmail = '';

  @observable
  bool isLoading = false;

  @observable
  String number = '';

  @observable
  String Name = '';

  @observable
  String Status = '';


  @observable
  String Email = '';

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    try {
      isLoggedIn = val;
      if (!isInitializing) await setValue(IS_LOGGED_IN, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting logged-in status: $e");
      }
    }
  }

  @action
  Future<void> setNumber(String val, {bool isInitializing = false}) async {
    try {
      number = val;
      if (!isInitializing) await setValue(NUMBER, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting number: $e");
      }
    }
  }

  @action
  Future<void> setName(String val, {bool isInitializing = false}) async {
    try {
      Name = val;
      if (!isInitializing) await setValue(NAME, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting first name: $e");
      }
    }
  }


  @action
  Future<void> setStatus(String val, {bool isInitializing = false}) async {
    try {
      Status = val;
      if (!isInitializing) await setValue(STATUS, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting first name: $e");
      }
    }
  }

  @action
  Future<void> setEmail(String val, {bool isInitializing = false}) async {
    try {
      Email = val;
      if (!isInitializing) await setValue(EMAIL, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting first name: $e");
      }
    }
  }


  @action
  Future<void> setToken(String val, {bool isInitializing = false}) async {
    try {
      token = val;
      if (!isInitializing) await setValue(TOKEN, val);
    } catch (e) {
      if (kDebugMode) {
        print("Error setting token: $e");
      }
    }
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void increment() {
    countryId++;
  }

  @action
  void decrement() {
    countryId--;
  }
}
