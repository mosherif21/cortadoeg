import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../connectivity/connectivity.dart';
import '../components/onboarding_page_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ConnectivityChecker.checkConnection(displayAlert: true);
    final screenHeight = getScreenHeight(context);
    final screenType = GetScreenType(context);
    return OnBoardingSlider(
      finishButtonText: 'continueApp'.tr,
      onFinish: () => displayChangeLang(),
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
      ),
      trailing: Text(
        'privacyPolicy'.tr,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailingFunction: () {},
      skipTextButton: AutoSizeText(
        'Skip'.tr,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      controllerColor: Colors.black,
      totalPage: 4,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      centerBackground: true,
      background: [
        for (int i = 1; i < 5; i++)
          Lottie.asset(
            'assets/lottie_animations/onBoardingAnim$i.json',
            height: i == 1 ? screenHeight * 0.7 : screenHeight * 0.6,
          )
      ],
      speed: 1.8,
      pageBodies: [
        for (int i = 1; i < 5; i++)
          OnboardingPageWidget(
            onBoardingTitle: 'onBoardingTitle$i'.tr,
            onBoardingDescription: 'onBoardingDescription$i'.tr,
            isPhone: screenType.isPhone,
          ),
      ],
    );
  }
}
