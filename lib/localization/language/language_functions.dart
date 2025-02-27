import 'package:cortadoeg/src/features/admin_side/sales/controllers/sales_screen_controller.dart';
import 'package:cortadoeg/src/general/common_widgets/today_date_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../src/authentication/authentication_repository.dart';
import '../../src/constants/enums.dart';
import '../../src/features/admin_side/custody_shifts/controllers/custody_screen_controller.dart';
import '../../src/features/cashier_side/orders/controllers/orders_controller.dart';
import '../../src/general/app_init.dart';
import '../../src/general/general_functions.dart';

const String languageCode = 'languageCode';

//languages code
const String english = 'en';
const String arabic = 'ar';

Future<void> setLocale(String aLanguageCode) async {
  await AppInit.prefs.setString(languageCode, aLanguageCode);
}

Future<bool> getIfLocaleIsSet() async {
  if (AppInit.prefs.getString(languageCode) != null) {
    return true;
  } else {
    return false;
  }
}

Locale getLocale() {
  String? aLanguageCode = AppInit.prefs.getString(languageCode);
  return locale(aLanguageCode!);
}

Locale locale(String aLanguageCode) {
  switch (aLanguageCode) {
    case english:
      AppInit.currentLanguage = Language.english;
      return const Locale(english, 'US');
    case arabic:
      AppInit.currentLanguage = Language.arabic;
      return const Locale(arabic, 'SA');
    default:
      AppInit.currentLanguage = Language.english;
      return const Locale(english, 'US');
  }
}

Future<void> setLocaleLanguage(String languageCode) async {
  if (Get.locale!.languageCode != languageCode) {
    await Get.updateLocale(locale(languageCode));
    await setLocale(languageCode);
    if (Get.isRegistered<DateController>()) {
      DateController.instance.updateDate();
    }
    if (Get.isRegistered<OrdersController>()) {
      OrdersController.instance.updateDateFilters();
    }
    if (Get.isRegistered<CustodyReportsController>()) {
      CustodyReportsController.instance.updateDateFilters();
    }
    if (Get.isRegistered<SalesScreenController>()) {
      SalesScreenController.instance.updateLanguagesFilters();
    }
    if (AppInit.isMobile) {
      AuthenticationRepository.instance.setNotificationsLanguage();
    }
    hideLoadingScreen();
  }
}
