import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/admin_main_screen/controllers/admin_main_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/account/components/models.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../components/employee_widget.dart';
import '../components/role_filter_widget.dart';
import '../controllers/employees_screen_controller.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final controller = Get.put(EmployeesScreenController());
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'employees'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      floatingActionButton: screenType.isPhone
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              tooltip: 'addEmployee'.tr,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () =>
                  controller.addEmployeeTap(isPhone: screenType.isPhone),
            )
          : null,
      body: StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: SingleChildScrollView(
          child: Column(
            children: [
              screenType.isPhone
                  ? AnimSearchAppBar(
                      keyboardType: TextInputType.text,
                      cancelButtonTextStyle:
                          const TextStyle(color: Colors.black87),
                      cancelButtonText: 'cancel'.tr,
                      hintText: 'searchEmployeesHint'.tr,
                      hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                      onChanged: controller.onEmployeesSearch,
                      backgroundColor: Colors.white,
                      appBar: const SizedBox.shrink(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AnimSearchAppBar(
                            keyboardType: TextInputType.text,
                            cancelButtonTextStyle:
                                const TextStyle(color: Colors.black87),
                            cancelButtonText: 'cancel'.tr,
                            hintText: 'searchEmployeesHint'.tr,
                            hintStyle:
                                const TextStyle(fontWeight: FontWeight.w600),
                            onChanged: controller.onEmployeesSearch,
                            backgroundColor: Colors.white,
                            appBar: const SizedBox.shrink(),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: IconTextElevatedButton(
                            buttonColor: Colors.black,
                            textColor: Colors.white,
                            borderRadius: 25,
                            fontSize: 16,
                            elevation: 0,
                            icon: Icons.add_rounded,
                            iconColor: Colors.white,
                            text: 'addEmployee'.tr,
                            onClick: () => controller.addEmployeeTap(
                                isPhone: screenType.isPhone),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              Obx(
                () => EmployeeRoleWidget(
                  selectedRole: controller.selectedRole.value,
                  onSelect: controller.onRoleSelect,
                ),
              ),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: !controller.loadingEmployees.value &&
                          controller.filteredEmployeesList.isEmpty
                      ? const SingleChildScrollView(child: NoEmployeesFound())
                      : AnimationLimiter(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenType.isPhone ? 2 : 4,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: screenType.isPhone
                                  ? 0.8
                                  : AdminMainScreenController
                                          .instance.navBarExtended.value
                                      ? 0.95
                                      : 1.05,
                            ),
                            itemCount: controller.loadingEmployees.value
                                ? 10
                                : controller.filteredEmployeesList.length,
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 300),
                                columnCount: screenType.isPhone ? 2 : 4,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: SizedBox(
                                      width: 200,
                                      height: 185,
                                      child: controller.loadingEmployees.value
                                          ? const LoadingEmployee()
                                          : EmployeeCard(
                                              profileImageUrl: controller
                                                  .filteredEmployeesList[index]
                                                  .profileImageUrl,
                                              name: controller
                                                  .filteredEmployeesList[index]
                                                  .name,
                                              role: getRoleName(controller
                                                  .filteredEmployeesList[index]
                                                  .role),
                                              gender: controller
                                                  .filteredEmployeesList[index]
                                                  .gender,
                                              onSelected: () =>
                                                  controller.onEmployeeTap(
                                                      index: index,
                                                      isPhone:
                                                          screenType.isPhone),
                                              onDelete: () => controller
                                                  .onDeleteEmployeeTap(
                                                      index: index),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              if (screenType.isPhone) const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class NoEmployeesFound extends StatelessWidget {
  const NoEmployeesFound({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          kNoCustomersAnim,
          fit: BoxFit.contain,
          height: screenHeight * 0.3,
        ),
        AutoSizeText(
          'noEmployeesFoundTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noEmployeesFoundBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }
}
