import 'package:cortadoeg/src/general/common_widgets/regular_card.dart';
import 'package:flutter/material.dart';

import '../../../connectivity/connectivity.dart';
import '../../../constants/assets_strings.dart';
import '../../../constants/sizes.dart';
import '../../../general/app_init.dart';
import '../../../general/common_widgets/language_change_button.dart';
import '../../../general/general_functions.dart';
import '../components/generalAuthComponents/authentication_form.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    ConnectivityChecker.checkConnection(displayAlert: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: Padding(
              padding: screenType.isPhone
                  ? const EdgeInsets.all(25)
                  : const EdgeInsets.only(
                      top: 15.0,
                      left: kDefaultPaddingSize,
                      right: 50,
                      bottom: kDefaultPaddingSize),
              child: screenType.isPhone
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ButtonLanguageSelect(color: Colors.black54),
                        Image(
                          image: const AssetImage(kLogoImage),
                          height: AppInit.notWebMobile
                              ? screenHeight * 0.39
                              : screenHeight * 0.32,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        const AuthenticationForm(),
                        const SizedBox(height: 20),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const ButtonLanguageSelect(color: Colors.black54),
                        SizedBox(height: screenHeight * 0.13),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image(
                              image: const AssetImage(kLogoImage),
                              height: screenHeight * 0.5,
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: RegularCard(
                                  padding: 35, child: AuthenticationForm()),
                            ),
                          ],
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
