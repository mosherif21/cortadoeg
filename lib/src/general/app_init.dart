import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/authentication/screens/auth_screen.dart';
import 'package:cortadoeg/src/features/onboarding_screen/screens/onboarding_screen.dart';
import 'package:cortadoeg/src/general/common_widgets/empty_scaffold.dart';
import 'package:cortadoeg/src/general/shared_preferences_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../localization/language/language_functions.dart';
import '../authentication/authentication_repository.dart';
import '../constants/enums.dart';
import '../features/cashier_side/main_screen/screens/main_screen.dart';
import '../firebase_files/firebase_intializatons.dart';
import 'error_widgets/no_internet_error_widget.dart';
import 'general_functions.dart';
import 'notifications.dart';

class AppInit {
  static bool showOnBoard = false;
  static bool notWebMobile = false;
  static bool isWeb = false;
  static bool isAndroid = false;
  static bool isIos = false;
  static bool webMobile = false;
  static bool isInitialised = false;
  static bool isConstantsInitialised = false;
  static bool splashRemoved = false;
  static late SharedPreferences prefs;
  static bool isLocaleSet = false;
  static late final Locale setLocale;
  static Language currentLanguage = Language.english;
  static InternetStatus initialInternetConnectionStatus =
      InternetStatus.disconnected;
  static String notificationToken = '';
  static final logger = Logger();
  static final currentAuthType = AuthType.emailLogin.obs;

  static Future<void> initializeConstants() async {
    if (!isConstantsInitialised) {
      await initializeDateFormatting('en_US', null);
      await initializeDateFormatting('ar', null);

      prefs = await SharedPreferences.getInstance();
      isLocaleSet = await getIfLocaleIsSet();
      showOnBoard = await getShowOnBoarding();
      if (isLocaleSet) {
        setLocale = getLocale();
      } else {
        setLocale = Get.deviceLocale ?? const Locale('en', 'US');
      }
      isWeb = kIsWeb;
      notWebMobile = isWeb &&
          !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);

      webMobile = isWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);

      if (defaultTargetPlatform == TargetPlatform.android && !isWeb) {
        isAndroid = true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS && !isWeb) {
        isIos = true;
      }
      isConstantsInitialised = true;
      SweetSheetColor.NICE = CustomSheetColor(
          main: const Color(0xEE28AADC),
          accent: Colors.black,
          icon: Colors.white);
    }
  }

  static Future<void> initializeDatabase() async {
    if (!isInitialised) {
      isInitialised = true;
      await initializeFireBaseApp();

      if (kDebugMode) {
        logger.i('firebase app initialized');
      }
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: false);
      if (isWeb || webMobile) {
        await activateWebAppCheck();
        if (kDebugMode) {
          logger.i('web app check initialized');
        }
      } else if (isAndroid) {
        await activateAndroidAppCheck();
        if (kDebugMode) {
          logger.i('android app check initialized');
        }
      } else if (isIos) {
        await activateIosAppCheck();
        if (kDebugMode) {
          logger.i('ios app check initialized');
        }
      }
      if (kDebugMode) {
        logger.i('Firebase initialized');
      }
      if (!AppInit.isWeb) {
        try {
          notificationToken = await FirebaseMessaging.instance.getToken() ?? '';
          initializeNotification();
        } catch (err) {
          if (kDebugMode) {
            logger.e(err.toString());
          }
        }
      }
      Get.put(AuthenticationRepository(), permanent: true);
    }
  }

  static Future<void> initialize() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await initializeConstants();
  }

  static Future<void> internetInitialize() async {
    if (!isInitialised) {
      AppInit.initializeDatabase().whenComplete(() async {
        if (!showOnBoard || isWeb) {
          await goToInitPage();
        }
      });
    }
  }

  static Future<void> noInternetInitializeCheck() async {
    if (!isInitialised) {
      removeSplashScreen();
      if (!showOnBoard || isWeb) {
        Get.offAll(() => const NotInternetErrorWidget());
      }
    }
  }

  static Future<void> goToInitPage() async {
    final authRepo = AuthenticationRepository.instance;
    if (authRepo.isUserLoggedIn) {
      final functionStatus = await authRepo.userInit();
      removeSplashScreen();
      if (functionStatus == FunctionStatus.success) {
        if (authRepo.userRole == Role.admin) {
          //
        } else if (authRepo.userRole == Role.cashier ||
            authRepo.userRole == Role.waiter ||
            authRepo.userRole == Role.takeaway) {
          Get.offAll(
            () => const MainScreen(),
            transition: Transition.circularReveal,
          );
        }
      } else {
        hideLoadingScreen();
        await authRepo.logoutAuthUser();
        showSnackBar(text: 'loginFailed'.tr, snackBarType: SnackBarType.error);
      }
    } else {
      removeSplashScreen();
      Get.offAll(
        () => const AuthenticationScreen(),
        transition: isWeb ? Transition.noTransition : Transition.circularReveal,
      );
    }
  }

  static Widget getInitialPage() {
    if (showOnBoard && !isWeb) removeSplashScreen();
    return showOnBoard && !isWeb
        ? const OnboardingScreen()
        : const EmptyScaffold();
  }

  static void removeSplashScreen() {
    if (!splashRemoved) {
      FlutterNativeSplash.remove();
      splashRemoved = true;
    }
  }
}
