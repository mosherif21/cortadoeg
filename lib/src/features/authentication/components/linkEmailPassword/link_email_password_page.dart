import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../connectivity/connectivity.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/common_widgets/regular_elevated_button.dart';
import '../../../../general/common_widgets/text_form_field.dart';
import '../../../../general/common_widgets/text_form_field_passwords.dart';
import '../../../../general/validation_functions.dart';
import '../../controllers/link_email_password_controller.dart';

class LinkEmailPasswordPage extends StatelessWidget {
  const LinkEmailPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConnectivityChecker.checkConnection(displayAlert: true);
    final controller = Get.put(LinkEmailPasswordController());
    return Form(
      key: controller.formKey,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const RegularBackButton(padding: 0),
          elevation: 0,
          backgroundColor: Colors.grey.shade100,
        ),
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: StretchingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'enterEmailPasswordDetails'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      minFontSize: 14,
                    ),
                    const SizedBox(height: 12),
                    Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormFieldRegular(
                            labelText: 'emailLabel'.tr,
                            hintText: 'emailHintLabel'.tr,
                            prefixIconData: Icons.email_outlined,
                            textController: controller.emailTextController,
                            inputType: InputType.email,
                            editable: true,
                            textInputAction: TextInputAction.next,
                            validationFunction: validateEmail,
                          ),
                          const SizedBox(height: 10),
                          TextFormFieldPassword(
                            labelText: 'passwordLabel'.tr,
                            textController: controller.passwordTextController,
                            textInputAction: TextInputAction.next,
                            validationFunction: validatePassword,
                          ),
                          const SizedBox(height: 10),
                          TextFormFieldPassword(
                            labelText: 'confirmPassword'.tr,
                            textController:
                                controller.passwordConfirmTextController,
                            textInputAction: TextInputAction.done,
                            validationFunction: validatePassword,
                          ),
                          const SizedBox(height: 12),
                          RegularElevatedButton(
                            buttonText: 'linkEmailPassword'.tr,
                            enabled: true,
                            onPressed: () => controller.linkEmailAndPassword(),
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
