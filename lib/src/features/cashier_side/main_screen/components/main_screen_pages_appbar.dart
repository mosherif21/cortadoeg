import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../general/common_widgets/today_date_widget.dart';
import 'notifications_button.dart';

class MainScreenPagesAppbar extends StatelessWidget {
  const MainScreenPagesAppbar(
      {super.key, required this.appBarTitle, required this.unreadNotification});
  final String appBarTitle;
  final bool unreadNotification;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150,
          child: AutoSizeText(appBarTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black),
              maxLines: 1),
        ),
        NotificationsButton(unreadNotification: unreadNotification),
        const TodayDateWidget(),
      ],
    );
  }
}
