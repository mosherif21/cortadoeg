import 'package:cortadoeg/src/features/authentication/screens/auth_screen.dart';
import 'package:cortadoeg/src/general/error_widgets/no_internet_error_widget.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/language/language_functions.dart';
import '../connectivity/connectivity_controller.dart';
import 'app_init.dart';
import 'general_functions.dart';

late SharedPreferences _prefs;
Future<void> setShowOnBoarding() async {
  _prefs = await SharedPreferences.getInstance();
  await _prefs.setString("onboarding", "true");
}

Future<bool> getShowOnBoarding() async {
  _prefs = await SharedPreferences.getInstance();
  if (_prefs.getString("onboarding") == "true") {
    return false;
  } else {
    return true;
  }
}

Future<void> setLocaleLanguageButton(String languageCode) async {
  Get.back();
  final currentLocale = Get.locale;
  if (currentLocale != null &&
      currentLocale.languageCode.compareTo(languageCode) == 0 &&
      !AppInit.showOnBoard) {
    return;
  }
  showLoadingScreen();
  if (AppInit.showOnBoard) {
    await setShowOnBoarding();
    await setLocaleLanguage(languageCode);
    AppInit.showOnBoard = false;
    Get.offAll(() => ConnectivityController.instance.internetConnected
        ? const AuthenticationScreen()
        : const NotInternetErrorWidget());
  } else {
    setLocaleLanguage(languageCode);
  }
}
