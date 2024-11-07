import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class NotInternetErrorWidget extends StatelessWidget {
  const NotInternetErrorWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    final height = getScreenHeight(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: screenType.isPhone
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      kNoInternetSwitchAnim,
                      fit: BoxFit.contain,
                      height: height * 0.5,
                    ),
                    AutoSizeText(
                      'noConnectionAlertTitle'.tr,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 5.0),
                    AutoSizeText(
                      'noConnectionAlertContent'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Lottie.asset(
                      kNoInternetSwitchAnim,
                      fit: BoxFit.contain,
                      height: height * 0.5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          'noConnectionAlertTitle'.tr,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 25.0,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5.0),
                        AutoSizeText(
                          'noConnectionAlertContent'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                        ),
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
