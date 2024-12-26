import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../authentication/authentication_repository.dart';
import '../../../constants/enums.dart';
import '../../../general/general_functions.dart';

class ResetPasswordController extends GetxController {
  static ResetPasswordController get instance => Get.find();
  final oldPasswordTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final passwordConfirmTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    if (formKey.currentState!.validate()) {
      final oldPassword = oldPasswordTextController.text;
      final password = passwordTextController.text;
      final passwordConfirm = passwordConfirmTextController.text;
      String returnMessage = '';
      FocusManager.instance.primaryFocus?.unfocus();
      showLoadingScreen();
      if (password == passwordConfirm &&
          password.length >= 8 &&
          oldPassword.length >= 8) {
        returnMessage = await AuthenticationRepository.instance
            .resetPassword(oldPassword, password);
      } else if (oldPassword.isEmpty ||
          password.isEmpty ||
          passwordConfirm.isEmpty) {
        returnMessage = 'emptyFields'.tr;
      } else if (password.length < 8) {
        returnMessage = 'smallPass'.tr;
      } else {
        returnMessage = 'passwordNotMatch'.tr;
      }
      hideLoadingScreen();
      if (returnMessage != 'success') {
        showSnackBar(
          text: returnMessage,
          snackBarType: SnackBarType.error,
        );
      } else {
        Get.back();
        showSnackBar(
          text: 'resetPasswordSuccess'.tr,
          snackBarType: SnackBarType.success,
        );
      }
    }
  }

  @override
  void onClose() {
    oldPasswordTextController.dispose();
    passwordTextController.dispose();
    passwordConfirmTextController.dispose();
    super.onClose();
  }
}
