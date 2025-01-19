import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/controllers/passcodes_screen_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../general/validation_functions.dart';

class PasscodeForm extends StatelessWidget {
  const PasscodeForm({super.key, required this.controller});
  final PasscodesScreenController controller;
  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenType.isPhone ? 16 : 50, horizontal: 25),
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!screenType.isPhone)
                Obx(
                  () => Text(
                    'passcodeOptionTitle${controller.chosenPasscodeOption.value + 1}'
                        .tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(height: screenType.isPhone ? 16 : 32),
              screenType.isPhone
                  ? Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'passcode'.tr,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: screenType.isPhone ? 18 : 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                controller: controller.passcodeController,
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.black,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: 'enterPasscode'.tr,
                                ),
                                validator: validatePasscode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'confirmPasscode'.tr,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: screenType.isPhone ? 18 : 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                controller:
                                    controller.confirmPasscodeController,
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.black,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: 'enterPasscodeConfirm'.tr,
                                ),
                                validator: validatePasscode,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'passcode'.tr,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenType.isPhone ? 18 : 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  controller: controller.passcodeController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    hintText: 'enterPasscode'.tr,
                                  ),
                                  validator: validatePasscode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'confirmPasscode'.tr,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: screenType.isPhone ? 18 : 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  controller:
                                      controller.confirmPasscodeController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    hintText: 'enterPasscodeConfirm'.tr,
                                  ),
                                  validator: validatePasscode,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: screenType.isPhone ? double.maxFinite : 400,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      overlayColor: Colors.grey,
                      surfaceTintColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () =>
                        controller.onSavePasscodeTap(screenType.isPhone),
                    child: Text(
                      'savePasscode'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
