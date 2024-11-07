import 'package:get/get.dart';

import 'connectivity_controller.dart';

class ConnectivityChecker {
  static void checkConnection({required bool displayAlert}) {
    if (Get.isRegistered<ConnectivityController>()) {
      ConnectivityController.instance
          .updateDisplayAlert(displayAlert: displayAlert);
    }
  }
}
