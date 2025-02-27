import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/account/components/models.dart';
import 'package:cortadoeg/src/features/admin_side/employees/components/permission_chip.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../authentication/models.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/rounded_elevated_button.dart';
import '../../../../general/validation_functions.dart';
import '../controllers/add_employee_controller.dart';

class AddEmployeeWidget extends StatelessWidget {
  const AddEmployeeWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEmployeeController());
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final isEnglish = isLangEnglish();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Get.delete<AddEmployeeController>();
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Form(
                                key: controller.formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'personalInformation'.tr,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AutoSizeText(
                                      'enterGender'.tr,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Row(
                                            children: [
                                              Text('male'.tr),
                                              Radio<String>(
                                                activeColor: Colors.black,
                                                hoverColor: Colors.black,
                                                focusColor: Colors.black,
                                                fillColor:
                                                    const WidgetStatePropertyAll(
                                                        Colors.black),
                                                value: 'male',
                                                groupValue:
                                                    controller.gender.value,
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    controller.gender.value =
                                                        value;
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 20),
                                              Text('female'.tr),
                                              Radio<String>(
                                                activeColor: Colors.black,
                                                hoverColor: Colors.black,
                                                focusColor: Colors.black,
                                                fillColor:
                                                    const WidgetStatePropertyAll(
                                                        Colors.black),
                                                value: 'female',
                                                groupValue:
                                                    controller.gender.value,
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    controller.gender.value =
                                                        value;
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildSectionTitle(
                                                  'firstName'.tr),
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextFormField(
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        100)
                                                  ],
                                                  controller: controller
                                                      .firstNameController,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor: Colors.black,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                  decoration: InputDecoration(
                                                    hintStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black54),
                                                    border: InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    filled: true,
                                                    fillColor: Colors.grey[200],
                                                    hintText:
                                                        'enterFirstName'.tr,
                                                  ),
                                                  validator: textNotEmpty,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildSectionTitle('lastName'.tr),
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextFormField(
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        100)
                                                  ],
                                                  controller: controller
                                                      .lastNameController,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor: Colors.black,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                  decoration: InputDecoration(
                                                    hintStyle: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black54),
                                                    border: InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    filled: true,
                                                    fillColor: Colors.grey[200],
                                                    hintText:
                                                        'enterLastName'.tr,
                                                  ),
                                                  validator: textNotEmpty,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('email'.tr),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextFormField(
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  100)
                                            ],
                                            controller:
                                                controller.emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            cursorColor: Colors.black,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              hintStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText: 'enterEmail'.tr,
                                            ),
                                            validator: validateEmail,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('password'.tr),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextFormField(
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  100)
                                            ],
                                            controller:
                                                controller.passwordController,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            cursorColor: Colors.black,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              hintStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText: 'enterPassword'.tr,
                                            ),
                                            validator: validatePassword,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('phoneNumber'.tr),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextFormField(
                                            textInputAction:
                                                TextInputAction.done,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  100)
                                            ],
                                            controller:
                                                controller.phoneController,
                                            keyboardType: TextInputType.phone,
                                            cursorColor: Colors.black,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              hintStyle: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              filled: true,
                                              fillColor: Colors.grey[200],
                                              hintText: 'enterPhoneNumber'.tr,
                                            ),
                                            validator: validateNumbersOnly,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('dateOfBirth'.tr),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () => controller
                                              .changeDateOfBirth(context),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: TextFormField(
                                              enabled: false,
                                              textInputAction:
                                                  TextInputAction.done,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    100)
                                              ],
                                              controller:
                                                  controller.dobController,
                                              keyboardType: TextInputType.name,
                                              cursorColor: Colors.black,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                suffixIcon: const Icon(
                                                    Icons.date_range_rounded),
                                                hintStyle: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black54),
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                                hintText: 'enterDateOfBirth'.tr,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                            _buildSectionTitle('employeeRole'.tr),
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
                                        fontWeight: FontWeight.w600,
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
                            _buildSectionTitle('employeePermissions'.tr),
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
                              buttonText: 'addEmployee'.tr,
                              onPressed: () => controller.onAddTap(),
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
        color: Colors.grey,
      ),
    );
  }
}
