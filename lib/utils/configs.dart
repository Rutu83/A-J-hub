

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';


// ignore: constant_identifier_names
const APP_NAME = 'TeaCup';
// ignore: constant_identifier_names
const APP_NAME_TAG_LINE = 'Business App';
var defaultPrimaryColor = const Color(0xFF070707);

// ignore: constant_identifier_names
const DOMAIN_URL = 'https://ajsystem.in/api/';
// ignore: constant_identifier_names
const Playstore_URL = 'https://play.google.com/store/apps/details?id=com.mdinfotech.teacup.teacup';
// ignore: constant_identifier_names
const BASE_URL = DOMAIN_URL;

// ignore: constant_identifier_names
const DEFAULT_LANGUAGE = 'en';


void snackBarMsgShow(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Registration successful'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void snackBarMsgShow2(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Login successful'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void snackBarMsgShow1(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Registration failed'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


void snackBarMsgShow3(BuildContext context) {
  const snackBar = SnackBar(
    content: Text('Login failed'),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '8849469980',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '+918849469980',
  );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
