import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:cortadoeg/src/features/admin_side/account/components/models.dart';
import 'package:cortadoeg/src/features/admin_side/employees/components/permission_chip.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/rounded_elevated_button.dart';
import '../controllers/employee_details_controller.dart';

class EmployeeEditDetailsPhone extends StatelessWidget {
  const EmployeeEditDetailsPhone({super.key, required this.employeeModel});
  final EmployeeModel employeeModel;
  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(EmployeeDetailsController(employeeModel: employeeModel));
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final isEnglish = isLangEnglish();
    final screenType = GetScreenType(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Timer(const Duration(milliseconds: 500),
            () => Get.delete<EmployeeDetailsController>());
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              height: 7,
              width: 40,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        margin: const EdgeInsets.only(top: 20),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          child: employeeModel.profileImageUrl.isNotEmpty
                              ? Image.network(
                                  employeeModel.profileImageUrl,
                                  height: screenHeight * 0.15,
                                  width: screenWidth * 0.3,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  employeeModel.gender == 'male'
                                      ? kMaleProfileImage
                                      : kFemaleProfileImage,
                                  height: screenHeight * 0.15,
                                  width: screenWidth * 0.3,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            employeeModel.name,
                            maxLines: 2,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Obx(
                            () => AutoSizeText(
                              getRoleName(controller.selectedRole.value),
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('changeRole'.tr),
                    const SizedBox(height: 10),
                    Obx(
                      () => SizedBox(
                        width: controller.selectedRole.value == Role.takeaway
                            ? isLangEnglish()
                                ? 200
                                : 240
                            : isLangEnglish()
                                ? 180
                                : 200,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<Role>(
                            isExpanded: true,
                            hint: Text(
                              'selectStatus'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: Role.values
                                .where((role) => role != Role.allRoles)
                                .where((role) {
                                  if (role == Role.admin ||
                                      role == Role.owner) {
                                    return hasPermission(
                                        AuthenticationRepository
                                            .instance.employeeInfo!,
                                        UserPermission.manageAdminAccounts);
                                  } else {
                                    return true;
                                  }
                                })
                                .map(
                                  (Role role) => DropdownMenuItem<Role>(
                                    value: role,
                                    child: Text(
                                      getRoleName(role),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            value: controller.selectedRole.value,
                            onChanged: (value) =>
                                controller.onRoleChanged(value!),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: isLangEnglish() ? 200 : 220,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSectionTitle('changePermission'.tr),
                    const SizedBox(height: 10),
                    Obx(
                      () {
                        final availablePermissions =
                            controller.getAvailablePermissions(
                                controller.selectedRole.value);
                        return Expanded(
                          child: StretchingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            child: SingleChildScrollView(
                              child: Column(
                                children: availablePermissions.map(
                                  (permission) {
                                    final isSelected = controller
                                        .currentPermissions
                                        .contains(permission);
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: PermissionChip(
                                        isPhone: screenType.isPhone,
                                        permission: permission,
                                        isSelected: isSelected,
                                        onChanged: (selected) =>
                                            controller.onPermissionToggled(
                                                permission, selected),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    RoundedElevatedButton(
                      enabled: true,
                      buttonText: 'saveChanges'.tr,
                      onPressed: () => controller.onSaveTap(),
                      color: Colors.black,
                      borderRadius: 10,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AutoSizeText(
      title,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.black54,
      ),
    );
  }
}
