import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationsButtonPhone extends StatelessWidget {
  const NotificationsButtonPhone({super.key, required this.unreadNotification});
  final bool unreadNotification;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(25),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashFactory: InkSparkle.splashFactory,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: unreadNotification
              ? const badges.Badge(
                  badgeContent: SizedBox(
                    height: 1,
                    width: 10,
                  ),
                  badgeStyle: badges.BadgeStyle(badgeColor: Colors.red),
                  child: Icon(
                    FontAwesomeIcons.bell,
                    color: Colors.black,
                    size: 25,
                  ),
                )
              : const Icon(
                  FontAwesomeIcons.bell,
                  color: Colors.black,
                  size: 25,
                ),
        ),
        onTap: () {
          // Get.to(
          //       () => const NotificationsScreen(),
          // );
        },
      ),
    );
  }
}
