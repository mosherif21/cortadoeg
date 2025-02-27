import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/common_widgets/back_button.dart';
import 'package:cortadoeg/src/general/common_widgets/regular_card.dart';
import 'package:cortadoeg/src/general/common_widgets/regular_elevated_button.dart';
import 'package:cortadoeg/src/general/common_widgets/text_form_field.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/sizes.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/text_form_field_passwords.dart';
import '../../controllers/change_email_controller.dart';

class EmailChangePage extends StatelessWidget {
  const EmailChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(ChangeEmailController());
    return Scaffold(
      appBar: AppBar(
        leading: const RegularBackButton(padding: 0),
        elevation: 0,
        centerTitle: screenType.isPhone,
        title: AutoSizeText(
          'changeEmail'.tr,
          maxLines: 1,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
              padding: screenType.isPhone
                  ? const EdgeInsets.all(25)
                  : const EdgeInsets.only(
                      top: 15.0,
                      left: kDefaultPaddingSize,
                      right: 60,
                      bottom: kDefaultPaddingSize),
              child: screenType.isPhone
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          kEmailVerificationAnim,
                          fit: BoxFit.contain,
                          height: screenHeight * 0.4,
                        ),
                        AutoSizeText(
                          'enterChangeEmailData'.tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: AppInit.notWebMobile ? 25 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          minFontSize: 10,
                        ),
                        const SizedBox(height: 20.0),
                        TextFormFieldRegular(
                          labelText: 'newEmailLabel'.tr,
                          hintText: 'newEmailHintLabel'.tr,
                          prefixIconData: Icons.email_outlined,
                          textController: controller.emailController,
                          inputType: InputType.email,
                          editable: true,
                          textInputAction: TextInputAction.done,
                          validationFunction: validateEmail,
                        ),
                        const SizedBox(height: 20.0),
                        TextFormFieldPassword(
                          labelText: 'passwordLabel'.tr,
                          textController: controller.passwordController,
                          textInputAction: TextInputAction.done,
                          validationFunction: validatePassword,
                        ),
                        const SizedBox(height: 20.0),
                        RegularElevatedButton(
                          buttonText: 'confirm'.tr,
                          enabled: true,
                          onPressed: () => controller.changeEmail(),
                          color: Colors.black,
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Lottie.asset(
                          kEmailVerificationAnim,
                          fit: BoxFit.contain,
                          height: screenHeight * 0.8,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: RegularCard(
                            padding: 35,
                            child: Column(
                              children: [
                                AutoSizeText(
                                  'enterChangeEmailData'.tr,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: AppInit.notWebMobile ? 25 : 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 10,
                                ),
                                const SizedBox(height: 20.0),
                                TextFormFieldRegular(
                                  labelText: 'newEmailLabel'.tr,
                                  hintText: 'newEmailHintLabel'.tr,
                                  prefixIconData: Icons.email_outlined,
                                  textController: controller.emailController,
                                  inputType: InputType.email,
                                  editable: true,
                                  textInputAction: TextInputAction.done,
                                  validationFunction: validateEmail,
                                ),
                                const SizedBox(height: 20.0),
                                TextFormFieldPassword(
                                  labelText: 'passwordLabel'.tr,
                                  textController: controller.passwordController,
                                  textInputAction: TextInputAction.done,
                                  validationFunction: validatePassword,
                                ),
                                const SizedBox(height: 20.0),
                                RegularElevatedButton(
                                  buttonText: 'confirm'.tr,
                                  enabled: true,
                                  onPressed: () => controller.changeEmail(),
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
