import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../authentication/authentication_repository.dart';
import '../../../constants/enums.dart';
import '../../../general/general_functions.dart';

class LinkEmailPasswordController extends GetxController {
  static LinkEmailPasswordController get instance => Get.find();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final passwordConfirmTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> linkEmailAndPassword() async {
    if (formKey.currentState!.validate()) {
      final email = emailTextController.text;
      final password = passwordTextController.text;
      final passwordConfirm = passwordConfirmTextController.text;
      String returnMessage = '';
      FocusManager.instance.primaryFocus?.unfocus();
      showLoadingScreen();
      if (password == passwordConfirm && password.length >= 8) {
        returnMessage = await AuthenticationRepository.instance
            .linkWithEmailAndPassword(email, password);
      } else if (email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
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
          text: 'emailPasswordAccountSuccess'.tr,
          snackBarType: SnackBarType.success,
        );
      }
    }
  }

  @override
  void onClose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    passwordConfirmTextController.dispose();
    super.onClose();
  }
}
