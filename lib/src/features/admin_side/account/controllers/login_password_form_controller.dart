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

class LoginPasswordFormController extends GetxController {
  late final String userId;
  late final User currentUser;
  late final EmployeeModel userInfo;
  late final AuthenticationRepository authRep;
  final verificationSent = false.obs;

  @override
  void onInit() async {
    authRep = AuthenticationRepository.instance;
    currentUser = authRep.fireUser.value!;
    userInfo = authRep.employeeInfo!;
    userId = currentUser.uid;
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

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
