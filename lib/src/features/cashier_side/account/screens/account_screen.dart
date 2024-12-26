import 'package:cortadoeg/src/features/cashier_side/account/components/account_options_list.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/login_password_form.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/account_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/account_options_list_phone.dart';
import '../components/personal_info_form.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(AccountScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenPagesAppbar(
                appBarTitle: 'account'.tr,
                unreadNotification: true,
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
            ? AccountOptionsListPhone(controller: controller)
            : Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: MainScreenController.instance.navBarExtended.value
                          ? 2
                          : 1,
                      child: AccountOptionsList(controller: controller),
                    ),
                    Expanded(
                      flex: MainScreenController.instance.navBarExtended.value
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
