import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../../authentication/authentication_repository.dart';
import '../../../constants/enums.dart';
import '../../../general/general_functions.dart';

class PasswordResetLinkController extends GetxController {
  static PasswordResetLinkController get instance => Get.find();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onReady() {
    final user = AuthenticationRepository.instance.fireUser.value;
    if (user != null) {
      if (user.email != null) {
        emailController.text = user.email!;
      }
    }
    super.onReady();
  }

  Future<void> resetPassword() async {
    if (formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      displayAlertDialog(
        title: 'confirm'.tr,
        body: 'resetUnlinkSocial'.tr,
        positiveButtonText: 'confirm'.tr,
        negativeButtonText: 'cancel'.tr,
        positiveButtonOnPressed: () async {
          Get.back();
          final email = emailController.text.trim();
          showLoadingScreen();
          String returnMessage = email.isEmpty
              ? 'missingEmail'.tr
              : !email.isEmail
                  ? 'invalidEmailEntered'.tr
                  : await AuthenticationRepository.instance
                      .sendResetPasswordLink(email: email);

          if (returnMessage == 'emailSent') {
            Get.back();
            showSnackBar(
              text: 'passwordResetSuccess'.tr,
              snackBarType: SnackBarType.success,
            );
          } else {
            showSnackBar(
              text: returnMessage,
              snackBarType: SnackBarType.error,
            );
          }
          hideLoadingScreen();
        },
        negativeButtonOnPressed: () => Get.back(),
        mainIcon: LineIcons.checkCircleAlt,
        color: CustomSheetColor(
            main: Colors.black, accent: Colors.black, icon: Colors.white),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
