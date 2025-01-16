import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';
import '../controllers/passcodes_screen_controller.dart';

class PasscodesOptionsList extends StatelessWidget {
  const PasscodesOptionsList({super.key, required this.controller});
  final PasscodesScreenController controller;
  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    final screenHeight = getScreenHeight(context);
    return Container(
      height: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            kPasscodeAnim,
            fit: BoxFit.contain,
            height: screenHeight * 0.3,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StretchingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Obx(
                    () => SizedBox(
                      height: 45,
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: index == controller.chosenPasscodeOption.value
                              ? null
                              : () => controller.onPasscodeOptionTap(
                                  index, screenType.isPhone),
                          splashFactory: InkSparkle.splashFactory,
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 30),
                                    AutoSizeText(
                                      'passcodeOption${index + 1}'.tr,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: index ==
                                                controller
                                                    .chosenPasscodeOption.value
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (index ==
                                  controller.chosenPasscodeOption.value)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: double.maxFinite,
                                  width: 5,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
