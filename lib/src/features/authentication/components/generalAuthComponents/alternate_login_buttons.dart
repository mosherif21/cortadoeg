import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/or_divider.dart';
import '../../../../general/general_functions.dart';

class AlternateLoginButtons extends StatelessWidget {
  const AlternateLoginButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton.mini(
              buttonType: ButtonType.google,
              onPressed: () async {
                showLoadingScreen();
                final returnMessage =
                    await AuthenticationRepository.instance.signInWithGoogle();
                if (returnMessage != 'success') {
                  hideLoadingScreen();
                  showSnackBar(
                    text: returnMessage,
                    snackBarType: SnackBarType.error,
                  );
                }
              },
            ),
            SignInButton.mini(
              buttonType: ButtonType.facebook,
              onPressed: () {
                // showLoadingScreen();
                // var returnMessage =
                //     await AuthenticationRepository.instance.signInWithFacebook();
                // if (returnMessage != 'success') {
                //   hideLoadingScreen();
                //   showSnackBar(
                //     text: returnMessage,
                //     snackBarType: SnackBarType.error,
                //   );
                // }
              },
            ),
          ],
        )
      ],
    );
  }
}
