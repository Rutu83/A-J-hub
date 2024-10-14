import 'package:allinone_app/local/language_en.dart';
import 'package:allinone_app/local/languages.dart';
import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/model/categories_mode.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/splash_screen.dart';
import 'package:allinone_app/store/app_store.dart';
import 'package:allinone_app/utils/common.dart';
import 'package:allinone_app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

final GlobalKey<NavigatorState> navigatorKeyNew = GlobalKey<NavigatorState>();
AppStore appStore = AppStore();
BaseLanguage language = LanguageEn();
List<UserData>? cachedUserData;
Map<String,dynamic>? cachedData;
List<BusinessModal>? cachedDashbord;
List<CategoriesResponse>? cachedHome;
List<SubcategoryResponse>? cachedsubcategory;


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  // set observer

  localeLanguageList = languageList();

  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
  if (appStore.isLoggedIn) {
    await appStore.setToken(getStringAsync(TOKEN), isInitializing: true);
    await appStore.setName(getStringAsync(NAME), isInitializing: true);
    await appStore.setEmail(getStringAsync(EMAIL), isInitializing: true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set the design s4ze for ScreenUtil
      builder: (context, child) {
        return MaterialApp(
          title: 'ALL IN ONE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white, // Sets the default background color for scaffolds
            cardColor: Colors.white, // Sets the default background color for cards
            dialogBackgroundColor: Colors.white, // Sets the default background color for dialogs
            popupMenuTheme: const PopupMenuThemeData(
              color: Colors.white, // Sets the default background color for dropdown popups
            ),
            textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}