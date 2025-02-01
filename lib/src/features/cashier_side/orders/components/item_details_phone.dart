import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/general/common_widgets/text_form_field_multiline.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../../../general/common_widgets/regular_elevated_button.dart';
import '../controllers/order_item_controller.dart';

class ItemDetailsPhone extends StatelessWidget {
  const ItemDetailsPhone({super.key, required this.item, this.orderItem});
  final ItemModel item;
  final OrderItemModel? orderItem;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        OrderItemController(itemModel: item, orderItemModel: orderItem));
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final isEnglish = isLangEnglish();
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Timer(const Duration(milliseconds: 500),
            () => Get.delete<OrderItemController>());
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              height: 7,
              width: 40,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(
                          item.name,
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        InputQty.int(
                          initVal: orderItem != null ? orderItem!.quantity : 1,
                          minVal: 1,
                          qtyFormProps:
                              const QtyFormProps(cursorColor: Colors.black),
                          decoration: const QtyDecorationProps(
                            isBordered: false,
                            borderShape: BorderShapeBtn.circle,
                            btnColor: Colors.black,
                            width: 10,
                          ),
                          onQtyChanged: (quantity) =>
                              controller.itemQuantity.value = quantity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AutoSizeText(
                      item.description,
                      maxLines: 3,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StretchingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('chooseSize'.tr),
                              CustomDropdown<String>(
                                items: controller.itemSizesStringList,
                                initialItem: orderItem != null
                                    ? controller.formattedSize(
                                        orderItem!.size, orderItem!.price)
                                    : controller.itemSizesStringList[0],
                                enabled:
                                    controller.itemSizesStringList.length > 1,
                                onChanged: (value) {
                                  controller.selectedSizeString = value;
                                  controller.selectedSize.value = item.sizes
                                      .where((size) =>
                                          controller.formattedSize(
                                              size.name, size.price) ==
                                          value)
                                      .first;
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: item.options.entries.map((option) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 5),
                                      _buildSectionTitle(
                                          option.key[0].toUpperCase() +
                                              option.key.substring(1)),
                                      CustomDropdown<String>(
                                        hintText: 'chooseOptions'.tr,
                                        initialItem: orderItem != null
                                            ? orderItem!.options[option.key]
                                            : null,
                                        items: option.value
                                            .map((optionVal) => optionVal.name)
                                            .toList(),
                                        onChanged: (value) {
                                          controller
                                                  .selectedOptions[option.key] =
                                              value!;
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 5),
                              _buildSectionTitle('chooseSugar'.tr),
                              CustomDropdown<String>(
                                items: controller.sugarLevelsStringList,
                                initialItem: orderItem != null
                                    ? orderItem!.sugarLevel
                                    : controller.sugarLevelsStringList[0],
                                enabled:
                                    controller.sugarLevelsStringList.length > 1,
                                onChanged: (value) {
                                  controller.selectedSugarLevel = value;
                                },
                              ),
                              _buildSectionTitle('notes'.tr),
                              const SizedBox(height: 10),
                              TextFormFieldMultiline(
                                hintText: 'typeNotes'.tr,
                                textController: controller.notesTextController,
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => RegularElevatedButton(
                        height: 55,
                        fontSize: 18,
                        enabled: true,
                        buttonText:
                            '${orderItem != null ? 'updateOrder'.tr : 'addToOrder'.tr} | EGP ${(controller.selectedSize.value.price * controller.itemQuantity.value).toStringAsFixed(2)}',
                        onPressed: () => controller.onAddTap(),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AutoSizeText(
      title,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
