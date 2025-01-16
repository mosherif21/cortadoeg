import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/general/common_widgets/text_form_field_multiline.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:input_quantity/input_quantity.dart';

import '../../../../general/common_widgets/rounded_elevated_button.dart';
import '../controllers/order_item_controller.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({super.key, required this.item, this.orderItem});
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
        Get.delete<OrderItemController>();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            height: screenHeight * 0.7,
            width: screenWidth * 0.7,
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 540),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    children: [
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: item.imageUrl != null
                                      ? BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 5,
                                            )
                                          ],
                                        )
                                      : null,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    child: item.imageUrl != null
                                        ? Image.network(
                                            item.imageUrl!,
                                            height: screenHeight * 0.35,
                                            width: double.infinity,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            kLogoImage,
                                            height: screenHeight * 0.35,
                                            width: double.infinity,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      item.name,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
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
                                  ],
                                ),
                                const SizedBox(height: 15),
                                InputQty.int(
                                  initVal: orderItem != null
                                      ? orderItem!.quantity
                                      : 1,
                                  minVal: 1,
                                  decoration: const QtyDecorationProps(
                                    isBordered: false,
                                    borderShape: BorderShapeBtn.circle,
                                    btnColor: Colors.black,
                                    width: 10,
                                  ),
                                  onQtyChanged: (quantity) =>
                                      controller.itemQuantity.value = quantity,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: StretchingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('chooseSize'.tr),
                                      CustomDropdown<String>(
                                        hintText: 'selectSize'.tr,
                                        items: controller.itemSizesStringList,
                                        initialItem: orderItem != null
                                            ? controller.formattedSize(
                                                orderItem!.size,
                                                orderItem!.price)
                                            : controller.itemSizesStringList[0],
                                        enabled: controller
                                                .itemSizesStringList.length >
                                            1,
                                        onChanged: (value) {
                                          controller.selectedSizeString = value;
                                          controller.selectedSize.value = item
                                              .sizes
                                              .where((size) =>
                                                  controller.formattedSize(
                                                      size.name, size.price) ==
                                                  value)
                                              .first;
                                        },
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            item.options.entries.map((option) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 16),
                                              _buildSectionTitle(
                                                  option.key[0].toUpperCase() +
                                                      option.key.substring(1)),
                                              CustomDropdown<String>(
                                                hintText: 'chooseOptions'.tr,
                                                initialItem: orderItem != null
                                                    ? orderItem!
                                                        .options[option.key]
                                                    : null,
                                                items: option.value
                                                    .map((optionVal) =>
                                                        optionVal.name)
                                                    .toList(),
                                                onChanged: (value) {
                                                  controller.selectedOptions[
                                                      option.key] = value!;
                                                },
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSectionTitle('chooseSugar'.tr),
                                      CustomDropdown<String>(
                                        hintText: 'selectSize'.tr,
                                        items: controller.sugarLevelsStringList,
                                        initialItem: orderItem != null
                                            ? orderItem!.sugarLevel
                                            : controller
                                                .sugarLevelsStringList[0],
                                        enabled: controller
                                                .sugarLevelsStringList.length >
                                            1,
                                        onChanged: (value) {
                                          controller.selectedSugarLevel = value;
                                        },
                                      ),
                                      _buildSectionTitle('notes'.tr),
                                      const SizedBox(height: 10),
                                      TextFormFieldMultiline(
                                        hintText: 'typeNotes'.tr,
                                        textController:
                                            controller.notesTextController,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () => RoundedElevatedButton(
                                enabled: true,
                                buttonText:
                                    '${orderItem != null ? 'updateOrder'.tr : 'addToOrder'.tr} | EGP ${(controller.selectedSize.value.price * controller.itemQuantity.value).toStringAsFixed(2)}',
                                onPressed: () => controller.onAddTap(),
                                color: Colors.black,
                                borderRadius: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: isEnglish ? 5 : null,
                  left: isEnglish ? null : 5,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AutoSizeText(
      title,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
