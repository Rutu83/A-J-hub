import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get skip;

  String get signInTitle;

  String get signInEmailLabel;

  String get signInPhone;
  String get signInPasswordLabel;

  String get signIn;

  String get forgotPassword;

  String get signInBottomTitle;

  String get signInJoinNow;

  String get signUp;

  String get signUpTitle;

  String get signUpNameLabel;

  String get signUpEmailLabel;

  String get signUpShopNameLabel;

  String get signUpPasswordLabel;

  String get selectCountry;

  String get selectState;

  String get selectCity;

  String get signUpPinCodeLabel;

  String get address;

  String get signUpBottomTitle;

  String get login;

  String get home;

  String get customer;

  String get profile;

  String get addCustomer;

  String get addTeaCoffee;

  String get addStaff;

  String get firstName;

  String get lastName;

  String get email;

  String get save;

  String get teaOrCoffeeTitle;

  String get selectCustomerLbl;

  String get tea;

  String get coffee;

  String get totalTea;

  String get totalCoffee;

  String get total;

  String get selectCustomer;

  String get searchLbl;

  String get hello;

  String get earning;

  String get appointments;

  String get totalRevenue;

  String get totalCustomer;

  String get teaOrCoffee;

  String get todayRevenue;

  String get recentDelivery;

  String get notification;

  String get todayRegister;

  String get report;

  String get totalSales;

  String get search;

  String get searchItemLbl;

  String get yourStaff;

  String get yourStaffDescription;

  String get notificationDescription;

  String get inviteYourFriends;

  String get inviteYourFriendsDescription;

  String get aboutUs;

  String get aboutUsDescription;

  String get helpCenter;

  String get helpCenterDescription;

  String get changePassword;

  String get changePasswordDescription;

  String get logout;

  String get deleteAccount;

  String get updateAccountTitle;

  String get nameLbl;

  String get update;

  String get oldPassword;

  String get currentPassword;

  String get confirmPassword;

  String get reset;

  String get getStarted;

  String get totalAmount;

  String get totalCup;

  String get currentMonth;

  String get cancel;

  String get ok;

  String get customerProfile;

  String get contactInfoTitle;

  String get communications;

  String get smsSetting;

  String get smsSettingDescription;

  String get disableCustomer;

  String get disableStaff;

  String get enableCustomer;

  String get enableStaff;

  String get deleteCustomerDescription;

  String get yes;

  String get no;

  String get staffMember;

  String get addStaffTitle;

  String get lblBOD;

  String get staffProfile;

  String get deleteStaffMember;

  String get thisMonth;

  String get selectLbl;

  String get lblTokenExpired;

  String get badRequest;

  String get forbidden;

  String get pageNotFound;

  String get tooManyRequests;

  String get badGateway;

  String get serviceUnavailable;

  String get gatewayTimeout;

  String get internalServerError;

  String get calender;

  String get favourite;

  String get loginSuccessfully;

  String get pleaseTryAgain;

  String get somethingWentWrong;

  String get lblRecheck;

  String get lblUnderMaintenance;

  String get lblCatchUpAfterAWhile;

  String get lblBackPressMsg;

  String get reload;

  String get lblNoChapterFound;

  String get lblNoTopicFound;

  String get noBookingSubTitle;

  String get lblNoBookingsFound;
}
