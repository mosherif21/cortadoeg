import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/regular_elevated_button.dart';
import '../../../../general/common_widgets/text_form_field.dart';
import '../../../../general/common_widgets/text_form_field_passwords.dart';
import '../../../../general/validation_functions.dart';
import '../../controllers/register_controller.dart';

class EmailRegisterForm extends StatelessWidget {
  const EmailRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailRegisterController());
    return Form(
      key: controller.formKey,
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
            textController: controller.passwordConfirmTextController,
            textInputAction: TextInputAction.done,
            onSubmitted: () => controller.registerNewUser(),
            validationFunction: validatePassword,
          ),
          const SizedBox(height: 12),
          RegularElevatedButton(
            buttonText: 'registerTextTitle'.tr,
            enabled: true,
            onPressed: () => controller.registerNewUser(),
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
