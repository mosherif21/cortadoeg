import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/text_form_field_multiline.dart';

class TransactionWidgetPhone extends StatelessWidget {
  const TransactionWidgetPhone({
    super.key,
    required this.controller,
  });
  final MainScreenController controller;
  @override
  Widget build(BuildContext context) {
    final statusSelectOptions = [
      'payIn'.tr,
      'payOut'.tr,
      'cashDrop'.tr,
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 5),
          AutoSizeText(
            'drawerTransactionTitle'.tr,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              AutoSizeText(
                'transactionType'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
              ),
              const SizedBox(width: 10),
              Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'selectStatus'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: statusSelectOptions
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    value: statusSelectOptions
                        .elementAt(controller.currentSelectedTransaction.value),
                    onChanged: (value) => value != null
                        ? controller.onTransactionTypeChanged(
                            statusSelectOptions.indexOf(value))
                        : controller.onTransactionTypeChanged(0),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      width: 140,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AutoSizeText(
                'enterAmount'.tr,
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
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: controller.drawerTransactionTextController,
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
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          TextFormFieldMultiline(
            hintText: 'typeTransactionDisc'.tr,
            textController: controller.drawerTransactionDescTextController,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final amount =
                    controller.drawerTransactionTextController.text.trim();
                final transactionDesc =
                    controller.drawerTransactionDescTextController.text.trim();
                if (isNumeric(amount)) {
                  controller.openDrawerTransaction(
                      description: transactionDesc,
                      amount: double.parse(amount),
                      transactionTypeIndex:
                          controller.currentSelectedTransaction.value);
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
                'confirm'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
