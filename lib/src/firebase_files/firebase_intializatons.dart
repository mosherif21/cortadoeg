import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../general/app_init.dart';
import 'firebase_options.dart';

Future<void> initializeFireBaseApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> activateWebAppCheck() async {
  await FirebaseAppCheck.instance
      .activate(
    webProvider:
        ReCaptchaV3Provider('6Ld7JcoqAAAAAPEJgTsYN3iSlvrABytso4Z2__Sw'),
  )
      .onError((error, stackTrace) {
    if (kDebugMode) {
      AppInit.logger.e(error.toString());
    }
  });
}

Future<void> activateAndroidAppCheck() async {
  await FirebaseAppCheck.instance
      .activate(
    androidProvider: AndroidProvider.debug,
    //androidProvider: AndroidProvider.playIntegrity,
  )
      .onError((error, stackTrace) {
    if (kDebugMode) {
      AppInit.logger.e(error.toString());
    }
  });
}

Future<void> activateIosAppCheck() async {
  await FirebaseAppCheck.instance
      .activate(
    appleProvider: AppleProvider.deviceCheck,
  )
      .onError((error, stackTrace) {
    if (kDebugMode) {
      AppInit.logger.e(error.toString());
    }
  });
}
