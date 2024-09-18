// ignore_for_file: constant_identifier_names

import 'package:nb_utils/nb_utils.dart';

/// DO NOT CHANGE THIS PACKAGE NAME
var appPackageName = isAndroid ? 'com.mdinfotech.teacup.teacup' : 'com.mdinfotech.teacup.teacup';
const String kregisterBox = "register_model";

//region Common Configs

const DEFAULT_FIREBASE_PASSWORD = '12345678';

const DECIMAL_POINT = 2;

const PER_PAGE_ITEM = 20;

const PER_PAGE_CATEGORY_ITEM = 50;

const LABEL_TEXT_SIZE = 14;
const double SETTING_ICON_SIZE = 18;
const double CATEGORY_ICON_SIZE = 70;

const double SUBCATEGORY_ICON_SIZE = 45;

const APP_BAR_TEXT_SIZE = 18;

const MARK_AS_READ = 'markas_read';

const PERMISSION_STATUS = 'permissionStatus';

const USER_PASSWORD = 'USER_PASSWORD';

const ONESIGNAL_TAG_KEY = 'appType';

const ONESIGNAL_TAG_VALUE = 'userApp';

const PER_PAGE_CHAT_LIST_COUNT = 50;


const USER_NOT_CREATED = "User not created";

const USER_CANNOT_LOGIN = "User can't login";

const USER_NOT_FOUND = "User not found";


const BOOKING_TYPE_ALL = 'all';

const CATEGORY_LIST_ALL = "all";


const BOOKING_TYPE_USER_POST_JOB = 'user_post_job';

const BOOKING_TYPE_SERVICE = 'service';


const DONE = 'Done';

const SERVICE = 'service';


const PAYMENT_STATUS_PAID = 'paid';


const NOTIFICATION_TYPE_BOOKING = 'booking';

const NOTIFICATION_TYPE_POST_JOB = 'post_Job';
//endregion

//region LIVESTREAM KEYS


const LIVESTREAM_UPDATE_ALL_STD_LIST = "UpdateAllStdList";

const LIVESTREAM_UPDATE_STD_SUBJECT_LIST = "LIVESTREAM_UPDATE_SUBJECT_LIST";

const LIVESTREAM_UPDATE_STD_CHAPTER_LIST = "LIVESTREAM_UPDATE_CHAPTER_LIST";

const LIVESTREAM_UPDATE_STD_TOPIC_LIST = "LIVESTREAM_UPDATE_TOPIC_LIST";

const LIVESTREAM_UPDATE_DASHBOARD = "streamUpdateDashboard";

const LIVESTREAM_START_TIMER = "startTimer";

const LIVESTREAM_PAUSE_TIMER = "pauseTimer";

const LIVESTREAM_UPDATE_BIDER = 'updateBiderData';
//endregion

//region THEME MODE TYPE

const THEME_MODE_LIGHT = 0;


const THEME_MODE_DARK = 1;

const THEME_MODE_SYSTEM = 2;
//endregion

// region Package Type

const PACKAGE_TYPE_SINGLE = 'single';

const PACKAGE_TYPE_MULTIPLE = 'multiple';
//endregion

//region SHARED PREFERENCES KEYS

const IS_FIRST_TIME = 'IsFirstTime';

const IS_LOGGED_IN = 'IS_LOGGED_IN';

const USER_ID = 'USER_ID';

const NAME = 'NAME';

const EMAIL = 'EMAIL';

const VENDOR_TYPE = 'VENDOR_TYPE';

const VENDOR = 'VENDOR';

const ROLE = 'ROLE';

const LAST_NAME = 'LAST_NAME';

const USER_STANDARD = 'USER_STANDARD';

const USER_MEDUIM = 'USER_MEDUIM';

const USER_EMAIL = 'USER_EMAIL';


const PROFILE_IMAGE = 'PROFILE_IMAGE';

const IS_REMEMBERED = "IS_REMEMBERED";

const TOKEN = 'TOKEN';

const USERNAME = 'USERNAME';

const DISPLAY_NAME = 'DISPLAY_NAME';
// ignore: constant_identifier_names
const CONTACT_NUMBER = 'CONTACT_NUMBER';
// ignore: constant_identifier_names
const COUNTRY_ID = 'COUNTRY_ID';
// ignore: constant_identifier_names
const STATE_ID = 'STATE_ID';
// ignore: constant_identifier_names
const CITY_ID = 'CITY_ID';
// ignore: constant_identifier_names
const ADDRESS = 'ADDRESS';

// ignore: constant_identifier_names
const PLAYERID = 'PLAYERID';
// ignore: constant_identifier_names
const UID = 'UID';
// ignore: constant_identifier_names
const LATITUDE = 'LATITUDE';
// ignore: constant_identifier_names
const LONGITUDE = 'LONGITUDE';
// ignore: constant_identifier_names
const CURRENT_ADDRESS = 'CURRENT_ADDRESS';
// ignore: constant_identifier_names
const LOGIN_TYPE = 'LOGIN_TYPE';
// ignore: constant_identifier_names
const PAYMENT_LIST = 'PAYMENT_LIST';
// ignore: constant_identifier_names
const USER_TYPE = 'USER_TYPE';
// ignore: constant_identifier_names
const IS_SELECTED = 'IS_SELECTED';
// ignore: constant_identifier_names
const HOUR_FORMAT_STATUS = 'HOUR_FORMAT_STATUS';
// ignore: constant_identifier_names
const PRIVACY_POLICY = 'PRIVACY_POLICY';
// ignore: constant_identifier_names
const TERM_CONDITIONS = 'TERM_CONDITIONS';
// ignore: constant_identifier_names
const INQUIRY_EMAIL = 'INQUIRY_EMAIL';
// ignore: constant_identifier_names
const HELPLINE_NUMBER = 'HELPLINE_NUMBER';
// ignore: constant_identifier_names
const USE_MATERIAL_YOU_THEME = 'USE_MATERIAL_YOU_THEME';
// ignore: constant_identifier_names
const IN_MAINTENANCE_MODE = 'inMaintenanceMode';
// ignore: constant_identifier_names
const HAS_IN_APP_STORE_REVIEW = 'hasInAppStoreReview1';
// ignore: constant_identifier_names
const HAS_IN_PLAY_STORE_REVIEW = 'hasInPlayStoreReview1';
// ignore: constant_identifier_names
const HAS_IN_REVIEW = 'hasInReview';
// ignore: constant_identifier_names
const SERVER_LANGUAGES = 'SERVER_LANGUAGES';
// ignore: constant_identifier_names
const AUTO_SLIDER_STATUS = 'AUTO_SLIDER_STATUS';
// ignore: constant_identifier_names
const UPDATE_NOTIFY = 'UPDATE_NOTIFY';
// ignore: constant_identifier_names
const CURRENCY_POSITION = 'CURRENCY_POSITION';
// ignore: constant_identifier_names
const ENABLE_USER_WALLET = 'ENABLE_USER_WALLET';
// ignore: constant_identifier_names
const SITE_DESCRIPTION = 'SITE_DESCRIPTION';
// ignore: constant_identifier_names
const SITE_COPYRIGHT = 'SITE_COPYRIGHT';
// ignore: constant_identifier_names
const FACEBOOK_URL = 'FACEBOOK_URL';
// ignore: constant_identifier_names
const INSTAGRAM_URL = 'INSTAGRAM_URL';
// ignore: constant_identifier_names
const TWITTER_URL = 'TWITTER_URL';
// ignore: constant_identifier_names
const LINKEDIN_URL = 'LINKEDIN_URL';
// ignore: constant_identifier_names
const YOUTUBE_URL = 'YOUTUBE_URL';
// ignore: constant_identifier_names
const APPLE_EMAIL = 'APPLE_EMAIL';
// ignore: constant_identifier_names
const APPLE_UID = 'APPLE_UID';
// ignore: constant_identifier_names
const APPLE_GIVE_NAME = 'APPLE_GIVE_NAME';
// ignore: constant_identifier_names
const APPLE_FAMILY_NAME = 'APPLE_FAMILY_NAME';


// ignore: constant_identifier_names
const APPSTORE_URL = 'APPSTORE_URL';
// ignore: constant_identifier_names
const PLAY_STORE_URL = 'PLAY_STORE_URL';
// ignore: constant_identifier_names
const PROVIDER_PLAY_STORE_URL = 'PROVIDER_PLAY_STORE_URL';
// ignore: constant_identifier_names
const PROVIDER_APPSTORE_URL = 'PROVIDER_APPSTORE_URL';
// ignore: constant_identifier_names
const BOOKING_ID_CLOSED_ = 'BOOKING_ID_CLOSED_';
// ignore: constant_identifier_names
const IS_ADVANCE_PAYMENT_ALLOWED = 'IS_ADVANCE_PAYMENT_ALLOWED';
// ignore: constant_identifier_names
const ADD_BOOKING = 'add_booking';
// ignore: constant_identifier_names
const ASSIGNED_BOOKING = 'assigned_booking';
// ignore: constant_identifier_names
const TRANSFER_BOOKING = 'transfer_booking';
// ignore: constant_identifier_names
const UPDATE_BOOKING_STATUS = 'update_booking_status';
// ignore: constant_identifier_names
const CANCEL_BOOKING = 'cancel_booking';
// ignore: constant_identifier_names
const PAYMENT_MESSAGE_STATUS = 'payment_message_status';
//endregion

// region APP CHANGE LOG
// ignore: constant_identifier_names
const FORCE_UPDATE = 'forceUpdate';
// ignore: constant_identifier_names
const FORCE_UPDATE_USER = 'forceUpdateInUser';
// ignore: constant_identifier_names
const USER_CHANGE_LOG = 'userChangeLog';
// ignore: constant_identifier_names
const LATEST_VERSIONCODE_USER_APP_ANDROID = 'latestVersionCodeUserAndroid';
// ignore: constant_identifier_names
const LATEST_VERSIONCODE_USER_APP_IOS = 'latestVersionCodeUseriOS';
//endregion


//Mobile  Parent Details
// ignore: constant_identifier_names
const TEA_PRICE = 'TEA_PRICE';
// ignore: constant_identifier_names
const MILK_PRICE = 'MILK_PRICE';
// ignore: constant_identifier_names
const NORMAL_WATER_PRICE = 'NORMAL_WATER_PRICE';
// ignore: constant_identifier_names
const COLDWATER_PRICE = 'COLDWATER_PRICE';
// ignore: constant_identifier_names
const COFFEE_PRICE = 'COFFEE_PRICE';
// ignore: constant_identifier_names
const PARENT_FIRST_NAME = 'PARENT_FIRST_NAME';
// ignore: constant_identifier_names
const SHOP_NAME = 'SHOP_NAME';
// ignore: constant_identifier_names
const PARENT_USERNAME = 'PARENT_USERNAME';
// ignore: constant_identifier_names
const PARENT_EMAIL = 'PARENT_EMAIL';
// ignore: constant_identifier_names
const PARENT_PHONE = 'PARENT_PHONE';
// ignore: constant_identifier_names
const PARENT_PROFILE = 'PARENT_PROFILE';
// ignore: constant_identifier_names
const PARENT_COUNTRY = 'PARENT_COUNTRY';
// ignore: constant_identifier_names
const PARENT_CITY = 'PARENT_CITY';
// ignore: constant_identifier_names
const PARENT_STATE = 'PARENT_STATE';
// ignore: constant_identifier_names
const PARENT_ZIP_CODE = 'PARENT_ZIP_CODE';
// ignore: constant_identifier_names
const PARENT_ADDRESS = 'PARENT_ADDRESS';
// ignore: constant_identifier_names
const NUMBER = 'NUMBER';
// ignore: constant_identifier_names
const CUSTOMERID = 'CUSTOMERID';
// ignore: constant_identifier_names
const PARENT_PROFESSION = 'PARENT_PROFESSION';
// ignore: constant_identifier_names
const PARENT_GENDER = 'PARENT_GENDER';


//region CURRENCY POSITION
// ignore: constant_identifier_names
const CURRENCY_POSITION_LEFT = 'left';
// ignore: constant_identifier_names
const CURRENCY_POSITION_RIGHT = 'right';
//endregion

//region CONFIGURATION KEYS
// ignore: constant_identifier_names
const CONFIGURATION_TYPE_CURRENCY = 'CURRENCY';
// ignore: constant_identifier_names
const CONFIGURATION_TYPE_CURRENCY_POSITION = 'CURRENCY_POSITION';
// ignore: constant_identifier_names
const CONFIGURATION_KEY_CURRENCY_COUNTRY_ID = 'CURRENCY_COUNTRY_ID';
// ignore: constant_identifier_names
const CURRENCY_COUNTRY_SYMBOL = 'CURRENCY_COUNTRY_SYMBOL';
// ignore: constant_identifier_names
const CURRENCY_COUNTRY_CODE = 'CURRENCY_COUNTRY_CODE';
// ignore: constant_identifier_names
const CURRENCY_COUNTRY_ID = 'CURRENCY_COUNTRY_ID';
// ignore: constant_identifier_names
const IS_CURRENT_LOCATION = 'CURRENT_LOCATION';
// ignore: constant_identifier_names
const ONESIGNAL_API_KEY = 'ONESIGNAL_API_KEY';
// ignore: constant_identifier_names
const ONESIGNAL_REST_API_KEY = 'ONESIGNAL_REST_API_KEY';
// ignore: constant_identifier_names
const ONESIGNAL_CHANNEL_KEY = 'ONESIGNAL_CHANNEL_ID';
// ignore: constant_identifier_names
const ONESIGNAL_APP_ID_PROVIDER = 'ONESIGNAL_ONESIGNAL_APP_ID_PROVIDER';
// ignore: constant_identifier_names
const ONESIGNAL_REST_API_KEY_PROVIDER = 'ONESIGNAL_ONESIGNAL_REST_API_KEY_PROVIDER';
// ignore: constant_identifier_names
const ONESIGNAL_CHANNEL_KEY_PROVIDER = 'ONESIGNAL_ONESIGNAL_CHANNEL_ID_PROVIDER';

//endregion

//region User Types
// ignore: constant_identifier_names
const USER_TYPE_STUDENT = 'student';
// ignore: constant_identifier_names
const USER_TYPE_TEACHER = 'teacher';
//endregion

//region LOGIN TYPE
// ignore: constant_identifier_names
const LOGIN_TYPE_USER = 'user';
// ignore: constant_identifier_names
const LOGIN_TYPE_GOOGLE = 'google';
// ignore: constant_identifier_names
const LOGIN_TYPE_OTP = 'mobile';
// ignore: constant_identifier_names
const LOGIN_TYPE_APPLE = 'apple';
//endregion

//region SERVICE TYPE
// ignore: constant_identifier_names
const SERVICE_TYPE_FIXED = 'fixed';
// ignore: constant_identifier_names
const SERVICE_TYPE_PERCENT = 'percent';
// ignore: constant_identifier_names
const SERVICE_TYPE_HOURLY = 'hourly';
// ignore: constant_identifier_names
const SERVICE_TYPE_FREE = 'free';
//endregion

//region PAYMENT METHOD
// ignore: constant_identifier_names
const PAYMENT_METHOD_COD = 'cash';
// ignore: constant_identifier_names
const PAYMENT_METHOD_STRIPE = 'stripe';
// ignore: constant_identifier_names
const PAYMENT_METHOD_RAZOR = 'razorPay';
// ignore: constant_identifier_names
const PAYMENT_METHOD_FLUTTER_WAVE = 'flutterwave';
// ignore: constant_identifier_names
const PAYMENT_METHOD_CINETPAY = 'cinet';
// ignore: constant_identifier_names
const PAYMENT_METHOD_SADAD_PAYMENT = 'sadad';
// ignore: constant_identifier_names
const PAYMENT_METHOD_FROM_WALLET = 'wallet';
// ignore: constant_identifier_names
const PAYMENT_METHOD_PAYPAL = 'paypal';
//endregion

//region SERVICE PAYMENT STATUS
// ignore: constant_identifier_names
const SERVICE_PAYMENT_STATUS_PAID = 'paid';
// ignore: constant_identifier_names
const PENDING_BY_ADMIN = 'pending_by_admin';
// ignore: constant_identifier_names
const SERVICE_PAYMENT_STATUS_ADVANCE_PAID = 'advanced_paid';
// ignore: constant_identifier_names
const SERVICE_PAYMENT_STATUS_PENDING = 'pending';
//endregion

//region FireBase Collection Name
// ignore: constant_identifier_names
const MESSAGES_COLLECTION = "messages";
// ignore: constant_identifier_names
const USER_COLLECTION = "users";
// ignore: constant_identifier_names
const CONTACT_COLLECTION = "contact";
// ignore: constant_identifier_names
const CHAT_DATA_IMAGES = "chatImages";

// ignore: constant_identifier_names
const IS_ENTER_KEY = "IS_ENTER_KEY";
// ignore: constant_identifier_names
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
// ignore: constant_identifier_names
const PER_PAGE_CHAT_COUNT = 50;
//endregion

//region BOOKING STATUS
// ignore: constant_identifier_names
const BOOKING_PAYMENT_STATUS_ALL = 'all';
// ignore: constant_identifier_names
const BOOKING_STATUS_PENDING = 'pending';
// ignore: constant_identifier_names
const BOOKING_STATUS_ACCEPT = 'accept';
// ignore: constant_identifier_names
const BOOKING_STATUS_ON_GOING = 'on_going';
// ignore: constant_identifier_names
const BOOKING_STATUS_IN_PROGRESS = 'in_progress';
// ignore: constant_identifier_names
const BOOKING_STATUS_HOLD = 'hold';
// ignore: constant_identifier_names
const BOOKING_STATUS_CANCELLED = 'cancelled';
// ignore: constant_identifier_names
const BOOKING_STATUS_REJECTED = 'rejected';

// ignore: constant_identifier_names
const BOOKING_STATUS_FAILED = 'failed';
// ignore: constant_identifier_names
const BOOKING_STATUS_COMPLETED = 'completed';
// ignore: constant_identifier_names
const BOOKING_STATUS_PENDING_APPROVAL = 'pending_approval';
// ignore: constant_identifier_names
const BOOKING_STATUS_WAITING_ADVANCED_PAYMENT = 'waiting';
// ignore: constant_identifier_names
const BOOKING_STATUS_PAID = 'paid';
// ignore: constant_identifier_names
const PAYMENT_STATUS_ADVANCE = 'advanced_paid';
//endregion

//region FILE TYPE
// ignore: constant_identifier_names
const TEXT = "TEXT";
// ignore: constant_identifier_names
const IMAGE = "IMAGE";

// ignore: constant_identifier_names
const VIDEO = "VIDEO";
// ignore: constant_identifier_names
const AUDIO = "AUDIO";
//endregion

//region CHAT LANGUAGE
// ignore: constant_identifier_names
const List<String> RTL_LanguageS = ['ar', 'ur'];
//endregion

//region MessageType
enum MessageType {
  // ignore: constant_identifier_names
  TEXT,
  // ignore: constant_identifier_names
  IMAGE,
  // ignore: constant_identifier_names
  VIDEO,
  // ignore: constant_identifier_names
  AUDIO,
}
//endregion

//region MessageExtension
extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}
//endregion

//region DateFormat
// ignore: constant_identifier_names
const DATE_FORMAT_1 = 'dd-MMM-yyyy hh:mm a';
// ignore: constant_identifier_names
const DATE_FORMAT_2 = 'd MMM, yyyy';
// ignore: constant_identifier_names
const DATE_FORMAT_3 = 'dd-MMM-yyyy';
// ignore: constant_identifier_names
const HOUR_12_FORMAT = 'hh:mm a';
// ignore: constant_identifier_names
const DATE_FORMAT_4 = 'dd MMM';
// ignore: constant_identifier_names
const DATE_FORMAT_7 = 'yyyy-MM-dd';
// ignore: constant_identifier_names
const DATE_FORMAT_8 = 'd MMM, yyyy hh:mm a';
// ignore: constant_identifier_names
const YEAR = 'yyyy';
// ignore: constant_identifier_names
const BOOKING_SAVE_FORMAT = "yyyy-MM-dd kk:mm:ss";
//endregion

//region Mail And Tel URL
// ignore: constant_identifier_names
const MAIL_TO = 'mailto:';
// ignore: constant_identifier_names
const TEL = 'tel:';
// ignore: constant_identifier_names
const GOOGLE_MAP_PREFIX = 'https://www.google.com/maps/search/?api=1&query=';

//endregion

SlideConfiguration sliderConfigurationGlobal = SlideConfiguration(duration: 400.milliseconds, delay: 50.milliseconds);

// region JOB REQUEST STATUS
// ignore: constant_identifier_names
const JOB_REQUEST_STATUS_REQUESTED = "requested";
// ignore: constant_identifier_names
const JOB_REQUEST_STATUS_ACCEPTED = "accepted";
// ignore: constant_identifier_names
const JOB_REQUEST_STATUS_ASSIGNED = "assigned";
// endregion

// ignore: constant_identifier_names
const PAYPAL_STATUS = 2;
