import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../authentication/authentication_repository.dart';
import '../../../constants/enums.dart';
import '../../../general/general_functions.dart';

class EmailRegisterController extends GetxController {
  static EmailRegisterController get instance => Get.find();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final passwordConfirmTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> registerNewUser() async {
    if (formKey.currentState!.validate()) {
      final email = emailTextController.text;
      final password = passwordTextController.text;
      final passwordConfirm = passwordConfirmTextController.text;
      String returnMessage = '';
      FocusManager.instance.primaryFocus?.unfocus();
      showLoadingScreen();
      if (password == passwordConfirm && password.length >= 8) {
        returnMessage = await AuthenticationRepository.instance
            .createUserWithEmailAndPassword(email, password);
      } else if (email.isEmpty || password.isEmpty || passwordConfirm.isEmpty) {
        returnMessage = 'emptyFields'.tr;
      } else if (password.length < 8) {
        returnMessage = 'smallPass'.tr;
      } else {
        returnMessage = 'passwordNotMatch'.tr;
      }
      if (returnMessage != 'success') {
        hideLoadingScreen();
        showSnackBar(
          text: returnMessage,
          snackBarType: SnackBarType.error,
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
