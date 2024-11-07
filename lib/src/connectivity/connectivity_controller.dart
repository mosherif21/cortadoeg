import 'dart:async';

import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../general/general_functions.dart';

class ConnectivityController extends GetxController {
  static ConnectivityController get instance => Get.find();
  late StreamSubscription _internetSubscription;
  bool _displayAlert = false;
  bool internetConnected = true;

  @override
  void onInit() {
    _internetSubscription = InternetConnection().onStatusChange.listen(
          (status) => _checkInternet(status),
        );
    super.onInit();
  }

  void _checkInternet(InternetStatus internetConnectionStatus) {
    if (internetConnectionStatus == InternetStatus.connected || AppInit.isWeb) {
      if (!internetConnected) {
        showSnackBar(
            text: 'connectionRestored'.tr, snackBarType: SnackBarType.success);
      }
      AppInit.internetInitialize();
      if (kDebugMode) {
        AppInit.logger.i('Connected to internet');
      }
      internetConnected = true;
    } else if (internetConnectionStatus == InternetStatus.disconnected) {
      internetConnected = false;
      if (_displayAlert) {
        showSnackBar(
            text: 'noConnectionAlertTitle'.tr,
            snackBarType: SnackBarType.warning);
      }
      if (kDebugMode) {
        AppInit.logger.i('Disconnected from internet');
      }
      AppInit.noInternetInitializeCheck();
    }
  }

  void updateDisplayAlert({required bool displayAlert}) {
    _displayAlert = displayAlert;
  }

  @override
  void onClose() async {
    super.onClose();
    await _internetSubscription.cancel();
  }
}
