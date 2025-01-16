import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/components/passcode_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
    if (isPhone) {
      Get.to(() => PasscodeForm(controller: this),
          transition: getPageTransition());
    } else {
      chosenPasscodeOption.value = index;
    }
  }

  void onSavePasscodeTap() {}

  // Future<FunctionStatus> saveEditOrderPasscode(String passcode) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('passcodes')
  //         .doc('passcodes')
  //         .set({
  //       'editOrderItemsHash': BCrypt.hashpw(
  //           isLangEnglish() ? passcode : translateArabicToEnglish(passcode),
  //           BCrypt.gensalt()),
  //     }, SetOptions(merge: true));
  //     return FunctionStatus.success;
  //   } on FirebaseException catch (error) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(error.toString());
  //     }
  //   } catch (err) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(err.toString());
  //     }
  //   }
  //   return FunctionStatus.failure;
  // }
  @override
  void onClose() async {
    //
    super.onClose();
  }
}
