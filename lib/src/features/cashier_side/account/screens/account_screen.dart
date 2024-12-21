import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/account_screen_controller.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';

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
        child: Row(
          children: [
            Container(
              height: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300, //New
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Obx(
                      () => controller.isProfileImageLoaded.value
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: controller
                                          .isProfileImageChanged.value
                                      ? XFileImage(
                                          controller.profileImage.value!)
                                      : controller.profileMemoryImage.value ??
                                          AssetImage(
                                            controller.userInfo.gender != null
                                                ? controller.userInfo.gender ==
                                                        'male'
                                                    ? kMaleProfileImage
                                                    : kFemaleProfileImage
                                                : kMaleProfileImage,
                                          ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: isLangEnglish() ? 10 : null,
                                  left: isLangEnglish() ? null : -3,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.black,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      splashFactory: InkSparkle.splashFactory,
                                      onTap: () => controller.onEditProfileTap(
                                        isPhone: screenType.isPhone,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  AutoSizeText(
                    controller.userInfo.name,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  AutoSizeText(
                    getRoleName(controller.userInfo.role),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getRoleName(Role role) {
    switch (role) {
      case Role.cashier:
        return 'cashier'.tr;
      case Role.takeaway:
        return 'takeawayRole'.tr;
      case Role.waiter:
        return 'waiter'.tr;
      case Role.admin:
        return 'admin'.tr;
    }
  }
}
