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

class EmployeeEditDetails extends StatelessWidget {
  const EmployeeEditDetails({super.key, required this.employeeModel});
  final EmployeeModel employeeModel;
  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(EmployeeDetailsController(employeeModel: employeeModel));
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final isEnglish = isLangEnglish();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Get.delete<EmployeeDetailsController>();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            height: screenHeight * 0.75,
            width: screenWidth * 0.7,
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 540),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  margin: const EdgeInsets.only(top: 20),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    child:
                                        employeeModel.profileImageUrl.isNotEmpty
                                            ? Image.network(
                                                employeeModel.profileImageUrl,
                                                height: screenHeight * 0.25,
                                                width: screenWidth * 0.25,
                                                fit: BoxFit.fill,
                                              )
                                            : Image.asset(
                                                employeeModel.gender == 'male'
                                                    ? kMaleProfileImage
                                                    : kFemaleProfileImage,
                                                height: screenHeight * 0.25,
                                                width: screenWidth * 0.25,
                                                fit: BoxFit.fill,
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      employeeModel.name,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Obx(
                                      () => AutoSizeText(
                                        getRoleName(
                                            controller.selectedRole.value),
                                        maxLines: 3,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildSectionTitle('changeRole'.tr),
                            const SizedBox(height: 10),
                            Obx(
                              () => SizedBox(
                                width: controller.selectedRole.value ==
                                        Role.takeaway
                                    ? 200
                                    : 180,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2<Role>(
                                    isExpanded: true,
                                    hint: Text(
                                      'selectStatus'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
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
                                                UserPermission
                                                    .manageAdminAccounts);
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
                                                fontSize: 16,
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height: 40,
                                      width: 180,
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
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: PermissionChip(
                                                permission: permission,
                                                isSelected: isSelected,
                                                onChanged: (selected) =>
                                                    controller
                                                        .onPermissionToggled(
                                                            permission,
                                                            selected),
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
                            const SizedBox(height: 16),
                            RoundedElevatedButton(
                              enabled: true,
                              buttonText: 'saveChanges'.tr,
                              onPressed: () => controller.onSaveTap(),
                              color: Colors.black,
                              borderRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: isEnglish ? 5 : null,
                  left: isEnglish ? null : 5,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AutoSizeText(
      title,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black54,
      ),
    );
  }
}
