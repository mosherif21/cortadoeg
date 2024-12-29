import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenDayShiftWidget extends StatelessWidget {
  const OpenDayShiftWidget({
    super.key,
    required this.openShiftPressed,
    required this.openingAmountTextController,
  });
  final Function openShiftPressed;
  final TextEditingController openingAmountTextController;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          width: 500,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              AutoSizeText(
                'enterOpeningShiftAmount'.tr,
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  AutoSizeText(
                    'openingAmount'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      controller: openingAmountTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintText: '0',
                        isDense: true,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final amount =
                              openingAmountTextController.text.trim();
                          if (isNumeric(amount)) {
                            Get.back();
                            openingAmountTextController.clear();
                            openShiftPressed(double.parse(amount));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          overlayColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.black,
                        ),
                        child: Text(
                          'openShift'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
