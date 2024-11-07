import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/assets_strings.dart';
import '../../constants/sizes.dart';
import '../general_functions.dart';

class NotAvailableErrorWidget extends StatelessWidget {
  const NotAvailableErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = getScreenHeight(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(kDefaultPaddingSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    kLogoImage,
                    height: height * 0.5,
                  ),
                  Column(
                    children: [
                      AutoSizeText(
                        'notAvailableErrorTitle'.tr,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 5.0),
                      AutoSizeText(
                        'notAvailableErrorSubTitle'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 2,
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
