import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../general/common_widgets/today_date_widget.dart';
import '../../../cashier_side/main_screen/components/notifications_button.dart';
import '../../../cashier_side/main_screen/components/notifications_buttons_phone.dart';
import '../controllers/admin_main_screen_controller.dart';

class MainScreenAppbar extends StatelessWidget {
  const MainScreenAppbar(
      {super.key, required this.appBarTitle, required this.isPhone});
  final String appBarTitle;
  final bool isPhone;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: isPhone ? null : 150,
          child: AutoSizeText(
            appBarTitle,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 1,
          ),
        ),
        Obx(
          () => isPhone
              ? NotificationsButtonPhone(
                  unreadNotification: AdminMainScreenController
                          .instance.notificationsCount.value >
                      0)
              : NotificationsButton(
                  unreadNotification: AdminMainScreenController
                          .instance.notificationsCount.value >
                      0),
        ),
        if (!isPhone) const TodayDateWidget(),
      ],
    );
  }
}
