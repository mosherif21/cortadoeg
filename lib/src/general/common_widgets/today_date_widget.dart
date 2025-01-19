import 'dart:async';

import 'package:cortadoeg/src/features/cashier_side/orders/controllers/orders_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../features/admin_side/custody_shifts/controllers/custody_screen_controller.dart';

class DateController extends GetxController {
  static DateController get instance => Get.find();
  var formattedDate = ''.obs; // Observable date string

  @override
  void onInit() {
    super.onInit();
    updateDate();
    _setDailyUpdate();
  }

  void updateDate() {
    formattedDate.value =
        DateFormat('EEE, dd MMM yyyy', isLangEnglish() ? 'en_US' : 'ar_SA')
            .format(DateTime.now());
  }

  void _setDailyUpdate() {
    DateTime now = DateTime.now();
    DateTime nextUpdate = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = nextUpdate.difference(now);
    Timer(timeUntilMidnight, () {
      updateDate();
      if (Get.isRegistered<OrdersController>()) {
        OrdersController.instance.updateNewDayDateFilters();
      }
      if (Get.isRegistered<CustodyReportsController>()) {
        CustodyReportsController.instance.updateNewDayDateFilters();
      }
      _setDailyUpdate();
    });
  }
}

class TodayDateWidget extends StatelessWidget {
  const TodayDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dateController = Get.put(DateController());

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(25),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            const Icon(
              FontAwesomeIcons.calendar,
              color: Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 10),
            Obx(
              () => Text(
                dateController.formattedDate.value,
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
