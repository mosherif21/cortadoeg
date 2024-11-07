import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';

class NoOrdersWidget extends StatelessWidget {
  const NoOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                kNoOrdersAnim,
                fit: BoxFit.contain,
                height: screenHeight * 0.5,
              ),
              AutoSizeText(
                'noActiveOrdersTitle'.tr,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
              const SizedBox(height: 5.0),
              AutoSizeText(
                'noActiveOrdersBody'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                maxLines: 2,
              ),
            ],
          )),
    );
  }
}
