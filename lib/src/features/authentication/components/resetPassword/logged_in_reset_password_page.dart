import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/sizes.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/common_widgets/regular_card.dart';
import '../../../../general/common_widgets/regular_elevated_button.dart';
import '../../../../general/common_widgets/text_form_field.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../../controllers/reset_password_controller.dart';

class LoggedInResetPasswordPage extends StatelessWidget {
  const LoggedInResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final controller = Get.put(ResetPasswordController());
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: AppBar(
        leading: screenType.isPhone
            ? const RegularBackButton(padding: 0)
            : const CircleBackButton(padding: 5),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
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
                        'loggedInPasswordResetLink'.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppInit.notWebMobile ? 25 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        minFontSize: 10,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Form(
                        key: controller.formKey,
                        child: TextFormFieldRegular(
                          labelText: 'emailLabel'.tr,
                          hintText: 'emailHintLabel'.tr,
                          prefixIconData: Icons.email_outlined,
                          textController: controller.emailController,
                          inputType: InputType.email,
                          editable: false,
                          textInputAction: TextInputAction.done,
                          validationFunction: validateEmail,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      RegularElevatedButton(
                        buttonText: 'send'.tr,
                        enabled: true,
                        onPressed: () => controller.resetPassword(),
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Lottie.asset(
                          kEmailVerificationAnim,
                          fit: BoxFit.contain,
                          height: screenHeight * 0.7,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: RegularCard(
                          padding: 30,
                          child: Column(
                            children: [
                              AutoSizeText(
                                'loggedInPasswordResetLink'.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppInit.notWebMobile ? 25 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                minFontSize: 10,
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Form(
                                key: controller.formKey,
                                child: TextFormFieldRegular(
                                  labelText: 'emailLabel'.tr,
                                  hintText: 'emailHintLabel'.tr,
                                  prefixIconData: Icons.email_outlined,
                                  textController: controller.emailController,
                                  inputType: InputType.email,
                                  editable: false,
                                  textInputAction: TextInputAction.done,
                                  validationFunction: validateEmail,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              RegularElevatedButton(
                                buttonText: 'send'.tr,
                                enabled: true,
                                onPressed: () => controller.resetPassword(),
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
