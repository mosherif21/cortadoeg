import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountWidget extends StatelessWidget {
  const DiscountWidget({
    super.key,
    required this.initialDiscountType,
    required this.initialDiscountValue,
    required this.percentageChosen,
    required this.onAddDiscount,
    required this.onCancel,
    required this.discountTextController,
  });
  final TextEditingController discountTextController;
  final String initialDiscountType;
  final double initialDiscountValue;
  final Function onAddDiscount;
  final Function onCancel;
  final RxBool percentageChosen;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addDiscount'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        percentageChosen.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.grey,
                        backgroundColor: percentageChosen.value
                            ? Colors.grey.shade200
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: percentageChosen.value
                            ? Colors.black54
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        percentageChosen.value = true;
                      },
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.grey,
                        backgroundColor: percentageChosen.value
                            ? Colors.black
                            : Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Icon(
                        Icons.percent_rounded,
                        color: percentageChosen.value
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      controller: discountTextController,
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => onCancel(),
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final discountText = discountTextController.text.trim();
                        if (isNumeric(discountText)) {
                          onAddDiscount(
                            percentageChosen.value ? 'percentage' : 'value',
                            double.parse(discountText),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        'add'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isNumeric(String str) {
    if (str.isEmpty) {
      showSnackBar(
          text: 'enterDiscountValue'.tr, snackBarType: SnackBarType.error);
      return false;
    } else if (double.tryParse(str) == null) {
      showSnackBar(text: 'enterNumber'.tr, snackBarType: SnackBarType.error);
      return false;
    } else {
      return true;
    }
  }
}
