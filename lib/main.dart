import 'dart:async'; // This is the missing import

import 'package:ajhub_app/firebase_optional.dart';
import 'package:ajhub_app/local/language_en.dart';
import 'package:ajhub_app/local/languages.dart';
import 'package:ajhub_app/model/business_mode.dart';
import 'package:ajhub_app/model/categories_mode.dart';
import 'package:ajhub_app/model/categories_subcategories_modal%20.dart';
import 'package:ajhub_app/model/daillyuse_modal.dart';
import 'package:ajhub_app/model/subcategory_model.dart';
import 'package:ajhub_app/model/team_model.dart';
import 'package:ajhub_app/model/user_data_modal.dart';
import 'package:ajhub_app/screens/transaction_history.dart';
import 'package:ajhub_app/splash_screen.dart';
import 'package:ajhub_app/store/app_store.dart';
import 'package:ajhub_app/utils/common.dart';
import 'package:ajhub_app/utils/constant.dart';
import 'package:ajhub_app/utils/notification_service.dart';
import 'package:ajhub_app/network/notification_service.dart' as model_ns; // Aliased import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';

import 'model/devotation_model.dart';
import 'model/devotation_model.dart';
import 'model/temple_model.dart';
import 'model/upcoming_model.dart';

final GlobalKey<NavigatorState> navigatorKeyNew = GlobalKey<NavigatorState>();
AppStore appStore = AppStore();
BaseLanguage language = LanguageEn();
List<UserData>? cachedUserData;
Map<String, dynamic>? cachedData;
List<BusinessModal>? cachedDashbord;
List<TeamModel>? cachedTeam;
List<TransactionHistory>? cachedTransaction;
List<CategoriesResponse>? cachedHome;
List<SubcategoryResponse>? cachedsubcategory;
List<DaillyuseResponse>? cacheddaillyusecategory;
List<DevotationuseResponse>? cacheddDevotionalusecategory;
List<CategoriesWithSubcategoriesResponse>? cachedcategorywithsubcategory;
List<SubcategoryResponse>? cachedTrendingSubcategory;
List<UpcomingSubcategoryResponse>? cachedAgricultureSubcategory;
List<UpcomingSubcategoryResponse>? cachedEntrepreneursSubcategory;
List<UpcomingSubcategoryResponse>? cachedTempleOfIndiaSubcategory;
List<UpcomingSubcategoryResponse>? cachedCelebrateTheMovementSubcategory;
// ADD THIS NEW LINE for the upcoming category cache
List<UpcomingSubcategoryResponse>? cachedUpcomingSubcategory;
List<Temple>? cachedTemples;
List<model_ns.NotificationModel>? cachedNotifications;
List<DaillyuseResponse>? cachedDirectSellingSubcategory;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await setupFlutterNotifications(); // Set up notifications
  await initialize();
  await initialize();
  localeLanguageList = languageList();
  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  if (appStore.isLoggedIn) {
    await appStore.setToken(getStringAsync(TOKEN), isInitializing: true);
    await appStore.setName(getStringAsync(NAME), isInitializing: true);
    await appStore.setEmail(getStringAsync(EMAIL), isInitializing: true);
    await appStore.setStatus(getStringAsync(STATUS), isInitializing: true);
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("Caught Flutter Error: ${details.exception}");
  };

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (payload) {
      if (payload != null) {
        OpenFilex.open(payload as String); // Open the PDF file
      }
    },
  );
  await NotificationService().init(); // <-- INITIALIZE NOTIFICATION SERVICE

  runApp(const MyApp());
}

Future<void> setupFlutterNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Request permission on iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    sound: true,
  );
  // Configure local notifications for background handling
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create Android notification channel for foreground notifications
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // ID
    'High Importance Notifications', // Name
    description:
        'This channel is used for important notifications.', // Description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message in the foreground: ${message.messageId}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked: ${message.data}');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// This function handles background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          // START OF NEW CODE TO FIX FONT SCALING
          builder: (context, widget) {
            // Get the MediaQueryData from the context.
            final mediaQueryData = MediaQuery.of(context);

            // Create a new MediaQuery with a fixed text scale factor.
            final constrainedTextScale = mediaQueryData.copyWith(
              // This line locks the font scaling to 1.0 (100%), ignoring system settings.
              // `textScaler` is the modern property for this.
              textScaler: const TextScaler.linear(1.0),

              // This line prevents the system's "Bold Text" accessibility setting
              // from affecting your app, ensuring consistent font weight.
              boldText: false,
            );

            // Return a new MediaQuery with the overridden data, wrapping your app.
            return MediaQuery(
              data: constrainedTextScale,
              child: widget!,
            );
          },
          // END OF NEW CODE
          title: 'ALL IN ONE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.red,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            dialogBackgroundColor: Colors.white,
            popupMenuTheme: const PopupMenuThemeData(
              color: Colors.white,
            ),
            textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
