import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/common_widgets/regular_card.dart';
import 'package:cortadoeg/src/general/common_widgets/regular_elevated_button.dart';
import 'package:cortadoeg/src/general/common_widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../constants/enums.dart';
import '../../constants/sizes.dart';
import '../../features/authentication/controllers/password_reset_link_controller.dart';
import '../app_init.dart';
import '../general_functions.dart';
import 'back_button.dart';

class SingleEntryScreen extends StatelessWidget {
  const SingleEntryScreen({
    super.key,
    required this.title,
    required this.lottieAssetAnim,
    required this.textFormTitle,
    required this.textFormHint,
    required this.buttonTitle,
    required this.prefixIconData,
    required this.inputType,
    this.validationFunction,
  });
  final String title;
  final String lottieAssetAnim;
  final String textFormTitle;
  final String textFormHint;
  final String buttonTitle;
  final IconData prefixIconData;
  final InputType inputType;
  final String? Function(String?)? validationFunction;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    if (inputType == InputType.email) {
      Get.put(PasswordResetLinkController());
    }
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
                        lottieAssetAnim,
                        fit: BoxFit.contain,
                        height: screenHeight * 0.4,
                      ),
                      AutoSizeText(
                        title,
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
                        key: PasswordResetLinkController.instance.formKey,
                        child: TextFormFieldRegular(
                          labelText: textFormTitle,
                          hintText: textFormHint,
                          prefixIconData: prefixIconData,
                          textController: PasswordResetLinkController
                              .instance.emailController,
                          inputType: inputType,
                          editable: true,
                          textInputAction: TextInputAction.done,
                          validationFunction: validationFunction,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      RegularElevatedButton(
                        buttonText: buttonTitle,
                        enabled: true,
                        onPressed: () {
                          final controller =
                              PasswordResetLinkController.instance;
                          controller.resetPassword();
                        },
                        color: Colors.black,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Lottie.asset(
                        lottieAssetAnim,
                        fit: BoxFit.contain,
                        height: screenHeight * 0.7,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: RegularCard(
                          padding: 35,
                          child: Column(
                            children: [
                              AutoSizeText(
                                title,
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
                                key: PasswordResetLinkController
                                    .instance.formKey,
                                child: TextFormFieldRegular(
                                  labelText: textFormTitle,
                                  hintText: textFormHint,
                                  prefixIconData: prefixIconData,
                                  textController: PasswordResetLinkController
                                      .instance.emailController,
                                  inputType: inputType,
                                  editable: true,
                                  textInputAction: TextInputAction.done,
                                  validationFunction: validationFunction,
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              RegularElevatedButton(
                                buttonText: buttonTitle,
                                enabled: true,
                                onPressed: () {
                                  final controller =
                                      PasswordResetLinkController.instance;
                                  controller.resetPassword();
                                },
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
