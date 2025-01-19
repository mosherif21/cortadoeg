import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/components/passcode_form_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';

class PasscodesScreenController extends GetxController {
  static PasscodesScreenController get instance => Get.find();
  final RxInt chosenPasscodeOption = 0.obs;
  final Rx<PasscodeType> chosenPasscodeType = PasscodeType.editOrderItems.obs;
  final passcodeController = TextEditingController();
  final confirmPasscodeController = TextEditingController();
  late final GlobalKey<FormState> formKey;
  @override
  void onInit() async {
    formKey = GlobalKey<FormState>();
    super.onInit();
  }

  @override
  void onReady() {
    //
    super.onReady();
  }

  void onPasscodeOptionTap(int index, bool isPhone) {
    chosenPasscodeType.value = PasscodeType.values[index];
    clearPasscodeValues();
    chosenPasscodeOption.value = index;
    FocusManager.instance.primaryFocus?.unfocus();
    if (isPhone) {
      Get.to(() => PasscodeFormScreen(controller: this),
          transition: getPageTransition());
    }
  }

  void clearPasscodeValues() {
    passcodeController.clear();
    confirmPasscodeController.clear();
  }

  void onSavePasscodeTap(bool isPhone) async {
    final passcodeText = passcodeController.text.trim();
    final passcodeConfirmText = confirmPasscodeController.text.trim();
    if (formKey.currentState!.validate()) {
      if (passcodeText == passcodeConfirmText) {
        showLoadingScreen();
        final saveStatus =
            await saveEditOrderPasscode(passcodeText, chosenPasscodeType.value);
        hideLoadingScreen();
        if (saveStatus == FunctionStatus.success) {
          FocusManager.instance.primaryFocus?.unfocus();
          clearPasscodeValues();
          if (isPhone) Get.back();
          showSnackBar(
            text: 'passCodeSaveSuccess'.tr,
            snackBarType: SnackBarType.success,
          );
        } else {
          showSnackBar(
            text: 'errorOccurred'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      } else {
        showSnackBar(
          text: 'passcodesMustMatch'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> saveEditOrderPasscode(
      String passcode, PasscodeType passcodeType) async {
    try {
      await FirebaseFirestore.instance
          .collection('passcodes')
          .doc('passcodes')
          .set({
        getPasscodeUpdateString(passcodeType): BCrypt.hashpw(
            isLangEnglish() ? passcode : translateArabicToEnglish(passcode),
            BCrypt.gensalt()),
      }, SetOptions(merge: true));
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
    return FunctionStatus.failure;
  }

  String getPasscodeUpdateString(PasscodeType passcodeType) {
    switch (passcodeType) {
      case PasscodeType.editOrderItems:
        return 'editOrderItemsHash';
      case PasscodeType.reopenOrders:
        return 'reopenOrdersHash';
      case PasscodeType.returnOrders:
        return 'returnOrdersHash';
      case PasscodeType.cancelOrders:
        return 'cancelOrdersHash';
      case PasscodeType.finalizeOrders:
        return 'finalizeOrdersHash';
      case PasscodeType.manageDayShift:
        return 'manageDayShiftHash';
      case PasscodeType.openDrawer:
        return 'openDrawerHash';
    }
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
