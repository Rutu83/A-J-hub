// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$tokenAtom = Atom(name: '_AppStore.token', context: context);

  @override
  String get token {
    _$tokenAtom.reportRead();
    return super.token;
  }

  @override
  set token(String value) {
    _$tokenAtom.reportWrite(value, super.token, () {
      super.token = value;
    });
  }

  late final _$isLoggedInAtom =
      Atom(name: '_AppStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$countryIdAtom =
      Atom(name: '_AppStore.countryId', context: context);

  @override
  int get countryId {
    _$countryIdAtom.reportRead();
    return super.countryId;
  }

  @override
  set countryId(int value) {
    _$countryIdAtom.reportWrite(value, super.countryId, () {
      super.countryId = value;
    });
  }

  late final _$loginTypeAtom =
      Atom(name: '_AppStore.loginType', context: context);

  @override
  String get loginType {
    _$loginTypeAtom.reportRead();
    return super.loginType;
  }

  @override
  set loginType(String value) {
    _$loginTypeAtom.reportWrite(value, super.loginType, () {
      super.loginType = value;
    });
  }

  late final _$userEmailAtom =
      Atom(name: '_AppStore.userEmail', context: context);

  @override
  String get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AppStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$numberAtom = Atom(name: '_AppStore.number', context: context);

  @override
  String get number {
    _$numberAtom.reportRead();
    return super.number;
  }

  @override
  set number(String value) {
    _$numberAtom.reportWrite(value, super.number, () {
      super.number = value;
    });
  }

  late final _$NameAtom = Atom(name: '_AppStore.Name', context: context);

  @override
  String get Name {
    _$NameAtom.reportRead();
    return super.Name;
  }

  @override
  set Name(String value) {
    _$NameAtom.reportWrite(value, super.Name, () {
      super.Name = value;
    });
  }

  late final _$StatusAtom = Atom(name: '_AppStore.Status', context: context);

  @override
  String get Status {
    _$StatusAtom.reportRead();
    return super.Status;
  }

  @override
  set Status(String value) {
    _$StatusAtom.reportWrite(value, super.Status, () {
      super.Status = value;
    });
  }

  late final _$EmailAtom = Atom(name: '_AppStore.Email', context: context);

  @override
  String get Email {
    _$EmailAtom.reportRead();
    return super.Email;
  }

  @override
  set Email(String value) {
    _$EmailAtom.reportWrite(value, super.Email, () {
      super.Email = value;
    });
  }

  late final _$planLimitsAtom =
      Atom(name: '_AppStore.planLimits', context: context);

  @override
  PlanLimits get planLimits {
    _$planLimitsAtom.reportRead();
    return super.planLimits;
  }

  @override
  set planLimits(PlanLimits value) {
    _$planLimitsAtom.reportWrite(value, super.planLimits, () {
      super.planLimits = value;
    });
  }

  late final _$setLoggedInAsyncAction =
      AsyncAction('_AppStore.setLoggedIn', context: context);

  @override
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) {
    return _$setLoggedInAsyncAction
        .run(() => super.setLoggedIn(val, isInitializing: isInitializing));
  }

  late final _$setNumberAsyncAction =
      AsyncAction('_AppStore.setNumber', context: context);

  @override
  Future<void> setNumber(String val, {bool isInitializing = false}) {
    return _$setNumberAsyncAction
        .run(() => super.setNumber(val, isInitializing: isInitializing));
  }

  late final _$setNameAsyncAction =
      AsyncAction('_AppStore.setName', context: context);

  @override
  Future<void> setName(String val, {bool isInitializing = false}) {
    return _$setNameAsyncAction
        .run(() => super.setName(val, isInitializing: isInitializing));
  }

  late final _$setStatusAsyncAction =
      AsyncAction('_AppStore.setStatus', context: context);

  @override
  Future<void> setStatus(String val, {bool isInitializing = false}) {
    return _$setStatusAsyncAction
        .run(() => super.setStatus(val, isInitializing: isInitializing));
  }

  late final _$setEmailAsyncAction =
      AsyncAction('_AppStore.setEmail', context: context);

  @override
  Future<void> setEmail(String val, {bool isInitializing = false}) {
    return _$setEmailAsyncAction
        .run(() => super.setEmail(val, isInitializing: isInitializing));
  }

  late final _$setTokenAsyncAction =
      AsyncAction('_AppStore.setToken', context: context);

  @override
  Future<void> setToken(String val, {bool isInitializing = false}) {
    return _$setTokenAsyncAction
        .run(() => super.setToken(val, isInitializing: isInitializing));
  }

  late final _$_AppStoreActionController =
      ActionController(name: '_AppStore', context: context);

  @override
  void setPlanLimits(PlanLimits limits) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setPlanLimits');
    try {
      return super.setPlanLimits(limits);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void increment() {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.increment');
    try {
      return super.increment();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrement() {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.decrement');
    try {
      return super.decrement();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
token: ${token},
isLoggedIn: ${isLoggedIn},
countryId: ${countryId},
loginType: ${loginType},
userEmail: ${userEmail},
isLoading: ${isLoading},
number: ${number},
Name: ${Name},
Status: ${Status},
Email: ${Email},
planLimits: ${planLimits}
    ''';
  }
}
