import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../constants/colors.dart';

class SideNavigationBar extends StatelessWidget {
  const SideNavigationBar({
    super.key,
    required SidebarXController controller,
    required bool isLangEnglish,
    required bool isPhone,
  })  : _controller = controller,
        _isLangEnglish = isLangEnglish,
        _isPhone = isPhone;

  final SidebarXController _controller;
  final bool _isLangEnglish;
  final bool _isPhone;
  @override
  Widget build(BuildContext context) {
    return SidebarX(
      showToggleButton: _isPhone ? false : true,
      animationDuration: _isPhone
          ? const Duration(milliseconds: 0)
          : const Duration(milliseconds: 300),
      controller: _controller,
      theme: SidebarXTheme(
        margin: EdgeInsets.only(
          left: _isLangEnglish ? 10 : 0,
          right: _isLangEnglish ? 0 : 10,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: EdgeInsets.only(
            left: _isLangEnglish ? 30 : 0, right: _isLangEnglish ? 0 : 30),
        selectedItemTextPadding: EdgeInsets.only(
            left: _isLangEnglish ? 30 : 0, right: _isLangEnglish ? 0 : 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Image.asset(kLogoDarkImage),
          ),
        );
      },
      items: [
        SidebarXItem(
            icon: Icons.table_bar,
            label: 'tables'.tr,
            onLongPress:
                (!_isPhone) ? () => _controller.toggleExtended() : null,
            onTap: (_isPhone) ? () => Get.back() : null,
            iconSize: 25),
        SidebarXItem(
            icon: FontAwesomeIcons.history,
            label: 'orders'.tr,
            onLongPress:
                (!_isPhone) ? () => _controller.toggleExtended() : null,
            onTap: (_isPhone) ? () => Get.back() : null,
            iconSize: 20),
        SidebarXItem(
            icon: FontAwesomeIcons.users,
            label: 'customers'.tr,
            onLongPress:
                (!_isPhone) ? () => _controller.toggleExtended() : null,
            onTap: (_isPhone) ? () => Get.back() : null,
            iconSize: 20),
        SidebarXItem(
            icon: Icons.person,
            label: 'account'.tr,
            onLongPress:
                (!_isPhone) ? () => _controller.toggleExtended() : null,
            onTap: (_isPhone) ? () => Get.back() : null,
            iconSize: 27),
        SidebarXItem(
            icon: Icons.settings,
            label: 'settings'.tr,
            onLongPress:
                (!_isPhone) ? () => _controller.toggleExtended() : null,
            onTap: (_isPhone) ? () => Get.back() : null,
            iconSize: 25),
      ],
    );
  }
}
