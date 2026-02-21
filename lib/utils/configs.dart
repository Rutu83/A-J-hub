// ignore_for_file: constant_identifier_names

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'AJ HUB';

const Playstore_URL =
    'https://play.google.com/store/apps/details?id=com.mdinfotech.teacup.teacup';

const APP_NAME_TAG_LINE = 'CUSTOMER APP';
var defaultPrimaryColor = const Color(0xFF070707);

// PRODUCTION URL (Restore when deploying)
const DOMAIN_URL = 'https://ajhub.co.in/api/';

// LOCAL TESTING URL (Android Emulator uses 10.0.2.2, iOS Simulator uses 127.0.0.1)
// const DOMAIN_URL = 'http://10.0.2.2:8000/api/'; // Android Emulator
// const DOMAIN_URL = 'http://10.67.249.99:8000/api/'; // Real Device (Hotspot IP)
// const DOMAIN_URL = 'http://127.0.0.1:8000/api/'; // iOS Simulator

const BASE_URL = DOMAIN_URL;

const DEFAULT_LANGUAGE = 'en';

void snackBarMsgShow(BuildContext context) {
  const snackBar = SnackBar(content: Text('Registration successful'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void snackBarMsgShow2(BuildContext context) {
  const snackBar = SnackBar(content: Text('Login successful'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void snackBarMsgShow1(BuildContext context) {
  const snackBar = SnackBar(content: Text('Registration failed'));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void snackBarMsgShow3(BuildContext context) {
  const snackBar = SnackBar(content: Text('Login failed'));
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
