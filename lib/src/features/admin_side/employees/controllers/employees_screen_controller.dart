import 'dart:async';
import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../components/add_employee.dart';
import '../components/add_employee_phone.dart';
import '../components/employee_details.dart';
import '../components/employee_details_phone.dart';

class EmployeesScreenController extends GetxController {
  static EmployeesScreenController get instance => Get.find();
  late List<EmployeeModel> employeesList;
  late List<EmployeeModel> roleFilteredEmployees;
  final RxList<EmployeeModel> filteredEmployeesList = <EmployeeModel>[].obs;
  final loadingEmployees = true.obs;
  final selectedRole = 0.obs;
  String searchText = '';
  late final StreamSubscription _employeesListener;

  @override
  void onInit() {
    //
    super.onInit();
  }

  @override
  void onReady() {
    listenToEmployees();
    super.onReady();
  }

  void onEmployeesSearch(String text) {
    if (!loadingEmployees.value) {
      searchText = text.trim().toUpperCase();
      filteredEmployeesList.value = searchText.isEmpty
          ? roleFilteredEmployees
          : roleFilteredEmployees
              .where((item) => item.name.toUpperCase().contains(searchText))
              .toList();
    }
  }

  void onRoleSelect(int selectedCatIndex) {
    if (!loadingEmployees.value) {
      selectedRole.value = selectedCatIndex;
      roleFilteredEmployees = selectedCatIndex == 0
          ? employeesList
          : employeesList
              .where(
                  (employee) => employee.role == Role.values[selectedCatIndex])
              .toList();
      filteredEmployeesList.value = searchText.isEmpty
          ? roleFilteredEmployees
          : roleFilteredEmployees
              .where((item) => item.name.toUpperCase().contains(searchText))
              .toList();
    }
  }

  void listenToEmployees() {
    final firestore = FirebaseFirestore.instance;

    _employeesListener =
        firestore.collection('employees').snapshots().listen((querySnapshot) {
      try {
        final currentUserEmail =
            AuthenticationRepository.instance.userEmail.value;

        employeesList = querySnapshot.docs
            .map((doc) => EmployeeModel.fromFirestore(doc.data(), doc.id))
            .where((employee) => employee.email != currentUserEmail)
            .toList();

        roleFilteredEmployees = employeesList;
        filteredEmployeesList.value = employeesList;
        loadingEmployees.value = false;
      } catch (error) {
        if (kDebugMode) {
          AppInit.logger.e(error.toString());
        }
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }, onError: (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    });
  }

  void addEmployeeTap({required bool isPhone}) {
    if (isPhone) {
      showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        duration: const Duration(milliseconds: 500),
        minHeight: 0,
        initHeight: 1,
        maxHeight: 1,
        anchors: [0, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return AddEmployeeWidgetPhone(scrollController: scrollController);
        },
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return const AddEmployeeWidget();
        },
      );
    }
  }

  void onEmployeeTap({required int index, required bool isPhone}) {
    if (isPhone) {
      showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        duration: const Duration(milliseconds: 500),
        minHeight: 0,
        initHeight: 0.95,
        maxHeight: 1,
        anchors: [0, 0.95, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return EmployeeEditDetailsPhone(
            employeeModel: filteredEmployeesList[index],
          );
        },
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return EmployeeEditDetails(
            employeeModel: filteredEmployeesList[index],
          );
        },
      );
    }
  }

  void onDeleteEmployeeTap({required int index}) => displayAlertDialog(
        title: 'deleteEmployee'.tr,
        body: 'deleteEmployeeConfirm'.tr,
        positiveButtonText: 'yes'.tr,
        negativeButtonText: 'no'.tr,
        positiveButtonOnPressed: () async {
          showLoadingScreen();
          final employeeId = filteredEmployeesList[index].id;
          final functionStatus =
              await deleteEmployeeFunctionCall(employeeId: employeeId);
          hideLoadingScreen();
          if (functionStatus == FunctionStatus.success) {
            Get.back();
            showSnackBar(
              text: 'employeeDeletedSuccessfully'.tr,
              snackBarType: SnackBarType.success,
            );
          } else {
            showSnackBar(
              text: 'errorOccurred'.tr,
              snackBarType: SnackBarType.error,
            );
          }
        },
        negativeButtonOnPressed: () => Get.back(),
        mainIcon: Icons.delete_outline_rounded,
        color: CustomSheetColor(
            main: Colors.black, accent: Colors.black, icon: Colors.white),
      );

  Future<FunctionStatus> deleteEmployeeFunctionCall(
      {required String employeeId}) async {
    final url =
        Uri.parse('https://deleteuserwithresources-e7icdbybjq-uc.a.run.app');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'employeeId': employeeId,
    });
    try {
      final response = await post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          AppInit.logger.i('Employee deleted successfully');
        }
        return FunctionStatus.success;
      } else {
        if (kDebugMode) {
          AppInit.logger.e('Notifications send failed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e('Notifications send failed ${e.toString()}');
      }
    }
    return FunctionStatus.failure;
  }

  @override
  void onClose() {
    _employeesListener.cancel();
    super.onClose();
  }
}
