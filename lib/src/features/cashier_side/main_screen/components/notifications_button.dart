import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../notifications/screens/notifications_screen.dart';

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key, required this.unreadNotification});
  final bool unreadNotification;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(25),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashFactory: InkSparkle.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              unreadNotification
                  ? const badges.Badge(
                      badgeContent: SizedBox(
                        height: 1,
                        width: 10,
                      ),
                      badgeStyle: badges.BadgeStyle(badgeColor: Colors.red),
                      child: Icon(
                        FontAwesomeIcons.bell,
                        color: Colors.black54,
                        size: 22,
                      ),
                    )
                  : const Icon(
                      FontAwesomeIcons.bell,
                      color: Colors.black54,
                      size: 22,
                    ),
              const SizedBox(width: 10),
              AutoSizeText(
                'notifications'.tr,
                style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
            ],
          ),
        ),
        onTap: () {
          Get.to(
            () => const NotificationsScreen(),
            transition: getPageTransition(),
          );
        },
      ),
    );
  }
}
