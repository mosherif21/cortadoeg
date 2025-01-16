import 'package:cortadoeg/src/features/admin_side/passcodes/components/passcode_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../../admin_main_screen/controllers/admin_main_screen_controller.dart';
import '../components/passcodes_options_list.dart';
import '../controllers/passcodes_screen_controller.dart';

class PasscodesScreen extends StatelessWidget {
  const PasscodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(PasscodesScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'passcodes'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: screenType.isPhone
            ? PasscodesOptionsList(controller: controller)
            : Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: AdminMainScreenController
                              .instance.navBarExtended.value
                          ? 2
                          : 1,
                      child: PasscodesOptionsList(controller: controller),
                    ),
                    Expanded(
                      flex: AdminMainScreenController
                              .instance.navBarExtended.value
                          ? 4
                          : 3,
                      child: PasscodeForm(controller: controller),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
