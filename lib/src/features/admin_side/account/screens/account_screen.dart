import 'package:cortadoeg/src/features/admin_side/admin_main_screen/components/main_appbar.dart';
import 'package:cortadoeg/src/features/admin_side/admin_main_screen/controllers/admin_main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/login_password_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../components/account_options_list.dart';
import '../components/account_options_list_phone.dart';
import '../components/personal_info_form.dart';
import '../controllers/account_screen_controller.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(AdminAccountScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                appBarTitle: 'account'.tr,
                isPhone: screenType.isPhone,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: screenType.isPhone
            ? AdminAccountOptionsListPhone(controller: controller)
            : Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: AdminMainScreenController
                              .instance.navBarExtended.value
                          ? 2
                          : 1,
                      child: AdminAccountOptionsList(controller: controller),
                    ),
                    Expanded(
                      flex: AdminMainScreenController
                              .instance.navBarExtended.value
                          ? 4
                          : 3,
                      child: Obx(
                        () => controller.chosenProfileOption.value == 0
                            ? const PersonalInfoForm()
                            : const LoginPasswordForm(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
