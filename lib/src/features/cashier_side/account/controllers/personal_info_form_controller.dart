import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../constants/enums.dart';
import '../../../../general/general_functions.dart';

class PersonalInfoFormController extends GetxController {
  late final String userId;
  late final User currentUser;
  late final EmployeeModel userInfo;
  late final AuthenticationRepository authRep;
  final gender = ''.obs;
  final verificationSent = false.obs;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  late final GlobalKey<FormState> formKey;
  @override
  void onInit() async {
    formKey = GlobalKey<FormState>();
    authRep = AuthenticationRepository.instance;
    currentUser = authRep.fireUser.value!;
    userInfo = authRep.employeeInfo!;
    userId = currentUser.uid;
    final nameParts = userInfo.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    gender.value = userInfo.gender ?? '';
    emailController.text = userInfo.email;
    phoneController.text = userInfo.phone;
    if (userInfo.birthDate != null) {
      dobController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(userInfo.birthDate!.toDate());
    }
    super.onInit();
  }

  @override
  void onReady() {
    //
    super.onReady();
  }

  void verifyEmail() async {
    showLoadingScreen();
    final functionStatus = await authRep.sendVerificationEmail();
    hideLoadingScreen();
    if (functionStatus == FunctionStatus.success) {
      showSnackBar(
          text: 'verifyEmailSent'.tr, snackBarType: SnackBarType.success);
      verificationSent.value = true;
    } else {
      showSnackBar(
          text: 'verifyEmailSendFailed'.tr, snackBarType: SnackBarType.error);
    }
  }

  void onSaveChanges() async {
    if (formKey.currentState!.validate()) {
      showLoadingScreen();
      final name =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}';
      final saveStatus = await authRep.updateEmployeePersonalInfo(
        name: name,
        phone: phoneController.text.trim(),
        birthDate: userInfo.birthDate!,
        gender: gender.value,
      );
      hideLoadingScreen();
      if (saveStatus == FunctionStatus.success) {
        showSnackBar(
            text: 'personalInfoSaveSuccess'.tr,
            snackBarType: SnackBarType.success);
      } else {
        showSnackBar(
            text: 'personalInfoSaveFailed'.tr,
            snackBarType: SnackBarType.error);
      }
    }
  }

  void changeDateOfBirth(BuildContext context) async {
    final results = await showCalendarDatePicker2Dialog(
      dialogBackgroundColor: Colors.white,
      context: context,
      value: [userInfo.birthDate?.toDate()],
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
        userInfo.birthDate = Timestamp.fromDate(results.first!);
      }
    }
  }

  @override
  void onClose() async {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
