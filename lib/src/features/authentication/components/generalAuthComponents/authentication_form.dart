import 'package:flutter/material.dart';

import '../loginScreen/login_form.dart';
import 'alternate_login_buttons.dart';

class AuthenticationForm extends StatelessWidget {
  const AuthenticationForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Obx(() => AppInit.currentAuthType.value == AuthType.emailLogin
        //     ?
        LoginForm()
        // : const EmailRegisterForm())
        ,
        AlternateLoginButtons(),
        //  SizedBox(height: screenHeight * 0.002),
        // Obx(
        //   () => RegularTextButton(
        //     buttonText: AppInit.currentAuthType.value == AuthType.emailLogin
        //         ? 'noEmailAccount'.tr
        //         : 'alreadyHaveAnAccount'.tr,
        //     onPressed: () =>
        //         AppInit.currentAuthType.value == AuthType.emailLogin
        //             ? AppInit.currentAuthType.value = AuthType.emailRegister
        //             : AppInit.currentAuthType.value = AuthType.emailLogin,
        //   ),
        // ),
      ],
    );
  }
}
