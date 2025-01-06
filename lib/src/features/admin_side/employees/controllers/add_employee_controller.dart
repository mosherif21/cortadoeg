import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../../../../constants/enums.dart';
import '../../../../general/general_functions.dart';

class AddEmployeeController extends GetxController {
  final Rx<Role> selectedRole = Role.cashier.obs;
  final RxList<UserPermission> currentPermissions = <UserPermission>[].obs;
  final gender = ''.obs;
  final verificationSent = false.obs;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  Timestamp dobTimestamp = Timestamp.now();
  late final GlobalKey<FormState> formKey;
  @override
  void onInit() async {
    formKey = GlobalKey<FormState>();
    phoneController.text = '+20';
    dobController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(dobTimestamp.toDate());
    super.onInit();
  }

  @override
  void onReady() {
    updatePermissionsBasedOnRole(selectedRole.value);
    super.onReady();
  }

  List<UserPermission> getAvailablePermissions(Role role) {
    if (role == Role.admin) {
      return rolePermissions[Role.admin]!;
    } else {
      return UserPermission.values
          .where((permission) =>
              !rolePermissions[Role.admin]!.contains(permission) ||
              rolePermissions[selectedRole.value]!.contains(permission))
          .toList();
    }
  }

  void updatePermissionsBasedOnRole(Role role) {
    currentPermissions.clear();
    if (rolePermissions.containsKey(role)) {
      currentPermissions.addAll(rolePermissions[role]!);
    }
  }

  void onPermissionToggled(UserPermission permission, bool isSelected) {
    final mutuallyExclusivePermissions = [
      if (permission.name.contains('WithPass'))
        UserPermission.values.firstWhere(
          (p) => p.name == permission.name.replaceAll('WithPass', ''),
          orElse: () => permission,
        )
      else
        UserPermission.values.firstWhere(
          (p) => p.name == '${permission.name}WithPass',
          orElse: () => permission,
        )
    ];

    currentPermissions
        .removeWhere((p) => mutuallyExclusivePermissions.contains(p));

    if (isSelected) {
      currentPermissions.add(permission);
    }
  }

  void onRoleChanged(Role role) {
    if (role != selectedRole.value) {
      selectedRole.value = role;
      updatePermissionsBasedOnRole(role);
    }
  }

  void changeDateOfBirth(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      dialogBackgroundColor: Colors.white,
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: Colors.black,
        selectedRangeHighlightColor: Colors.grey.shade200,
        daySplashColor: Colors.grey.shade200,
        calendarType: CalendarDatePicker2Type.single,
      ),
      dialogSize: const Size(475, 375),
      borderRadius: BorderRadius.circular(15),
    );
    if (results != null) {
      if (results.first != null) {
        dobController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(results.first!);
        dobTimestamp = Timestamp.fromDate(results.first!);
      }
    }
  }

  Future<void> onAddTap() async {
    if (!formKey.currentState!.validate() || gender.value.isEmpty) {
      showSnackBar(
        text: 'missingEmployeeInfo'.tr,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    try {
      showLoadingScreen();
      final callable = FirebaseFunctions.instance.httpsCallable('addEmployee');
      final url = Uri.parse('https://addemployee-e7icdbybjq-uc.a.run.app');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'name': '${firstNameController.text} ${lastNameController.text}',
        'email': emailController.text,
        'password': passwordController.text,
        'phone': phoneController.text,
        'birthDate': dobTimestamp.toDate().toIso8601String(),
        'gender': gender.value,
        'role': selectedRole.value.name,
        'permissions':
            currentPermissions.map((UserPermission e) => e.name).toList(),
      });
      final response = await post(url, headers: headers, body: body);
      hideLoadingScreen();
      if (response.statusCode == 200) {
        Get.back();
        showSnackBar(
          text: 'employeeAddedSuccessfully'.tr,
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      hideLoadingScreen();
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  void onClose() async {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
