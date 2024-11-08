import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../general/common_widgets/today_date_widget.dart';
import 'notifications_button.dart';
import 'notifications_buttons_phone.dart';

class MainScreenPagesAppbar extends StatelessWidget {
  const MainScreenPagesAppbar(
      {super.key,
      required this.appBarTitle,
      required this.unreadNotification,
      required this.isPhone});
  final String appBarTitle;
  final bool unreadNotification;
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
        isPhone
            ? NotificationsButtonPhone(unreadNotification: unreadNotification)
            : NotificationsButton(unreadNotification: unreadNotification),
        if (!isPhone) const TodayDateWidget(),
      ],
    );
  }
}
