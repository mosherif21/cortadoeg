import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';

class EmployeeDetailsController extends GetxController {
  final EmployeeModel employeeModel;
  final Rx<Role> selectedRole = Role.cashier.obs;
  final RxList<UserPermission> currentPermissions = <UserPermission>[].obs;

  EmployeeDetailsController({
    required this.employeeModel,
  });

  @override
  void onInit() async {
    //
    super.onInit();
  }

  @override
  void onReady() {
    selectedRole.value = employeeModel.role;
    currentPermissions.value = employeeModel.permissions;
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

  void onSaveTap() async {
    showLoadingScreen();
    final saveStatus = await updateEmployee();
    hideLoadingScreen();
    if (saveStatus == FunctionStatus.success) {
      Get.back();
      showSnackBar(
          text: 'personalInfoSaveSuccess'.tr,
          snackBarType: SnackBarType.success);
    } else {
      showSnackBar(
          text: 'personalInfoSaveFailed'.tr, snackBarType: SnackBarType.error);
    }
  }

  Future<FunctionStatus> updateEmployee() async {
    final firestoreUsersCollRef =
        FirebaseFirestore.instance.collection('employees');
    try {
      await firestoreUsersCollRef.doc(employeeModel.id).update({
        'role': selectedRole.value.name,
        'permissions': currentPermissions.map((p) => p.name).toList(),
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return FunctionStatus.failure;
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
