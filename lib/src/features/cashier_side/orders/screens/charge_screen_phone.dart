import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../components/check_out_item_phone.dart';
import '../controllers/order_controller.dart';

class ChargeScreenPhone extends StatelessWidget {
  const ChargeScreenPhone({super.key, required this.controller});
  final OrderController controller;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const RegularBackButton(padding: 0),
        title: Text(
          'checkOut'.tr,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.grey.shade100,
      ),
      backgroundColor: Colors.grey.shade100,
      body: DraggableBottomSheet(
        minExtent: 105,
        barrierDismissible: false,
        useSafeArea: false,
        curve: Curves.easeIn,
        maxExtent: screenHeight * 0.47,
        barrierColor: Colors.transparent,
        duration: const Duration(milliseconds: 200),
        onDragging: (pos) {},
        previewWidget: Material(
          elevation: 10,
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    height: 7,
                    width: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'totalAmount'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '\$${controller.orderTotal.value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 55,
                          width: 150,
                          child: Obx(
                            () => IconTextElevatedButton(
                              buttonColor: Colors.black,
                              textColor: Colors.white,
                              borderRadius: 15,
                              fontSize: 20,
                              elevation: 0,
                              icon: Icons.payments_outlined,
                              iconColor: Colors.white,
                              text: 'charge'.tr,
                              enabled: controller.orderItems.isNotEmpty,
                              onClick: () => Get.to(
                                () => ChargeScreenPhone(controller: controller),
                                transition: getPageTransition(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        expandedWidget: Material(
          elevation: 10,
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                ),
                height: 7,
                width: 40,
              ),
              const SizedBox(height: 15),
              AutoSizeText(
                'paymentDetails'.tr,
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                maxLines: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Obx(
                  () => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'subtotal'.tr,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '\$${controller.orderSubtotal.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(
                          left: isLangEnglish()
                              ? 20
                              : controller.discountAmount.value > 0
                                  ? 2
                                  : 20,
                          right: isLangEnglish()
                              ? controller.discountAmount.value > 0
                                  ? 2
                                  : 20
                              : 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'discountSales'.tr,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.discountAmount.value > 0
                                  ? () => controller.onCancelDiscount()
                                  : null,
                              child: Row(
                                children: [
                                  Text(
                                    '-\$${controller.discountAmount.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                  if (controller.discountAmount.value > 0)
                                    const Icon(
                                      size: 15,
                                      Icons.cancel_rounded,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'totalSalesTax'.tr,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '\$${controller.orderTax.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              '\$${controller.orderTotal.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: IconTextElevatedButton(
                            buttonColor: Colors.black,
                            textColor: Colors.white,
                            borderRadius: 15,
                            elevation: 0,
                            icon: Icons.discount_outlined,
                            iconColor: Colors.white,
                            text: controller.discountAmount.value > 0
                                ? 'editDiscount'.tr
                                : 'addDiscount'.tr,
                            onClick: () => controller.addDiscountPhone(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: IconTextElevatedButton(
                            buttonColor: Colors.black,
                            textColor: Colors.white,
                            borderRadius: 15,
                            elevation: 0,
                            icon: controller.currentCustomerName.value ==
                                    'noCustomer'.tr
                                ? Icons.person
                                : Icons.close_rounded,
                            iconColor: Colors.white,
                            text: controller.currentCustomerName.value ==
                                    'noCustomer'.tr
                                ? 'addCustomer'.tr
                                : 'removeCustomer'.tr,
                            onClick: () =>
                                controller.currentCustomerName.value ==
                                        'noCustomer'.tr
                                    ? controller.onCustomerChoose(context)
                                    : controller.onRemoveCustomer(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 55,
                  child: Obx(
                    () => IconTextElevatedButton(
                      buttonColor: Colors.black,
                      textColor: Colors.white,
                      borderRadius: 15,
                      fontSize: 20,
                      elevation: 0,
                      icon: Icons.payments_outlined,
                      iconColor: Colors.white,
                      enabled: controller.orderItems.isNotEmpty,
                      text:
                          '${'charge'.tr} | \$${controller.orderTotal.value.toStringAsFixed(2)}',
                      onClick: () => Get.to(
                        () => ChargeScreenPhone(controller: controller),
                        transition: getPageTransition(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundWidget: Column(
          children: [
            Expanded(
              child: Obx(
                () => StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.down,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: controller.orderItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: CheckOutItemPhone(
                          orderItemModel: controller.orderItems[index],
                          onEditTap: () => controller.onEditItem(
                              index, context, screenType.isPhone),
                          onDeleteTap: () => controller.onDeleteItem(index),
                          onDismissed: () => controller.onDeleteItem(index),
                          index: index,
                          onQuantityChanged: (newQuantity) {
                            final orderItem = controller.orderItems[index];
                            controller.orderItems[index] = OrderItemModel(
                              name: orderItem.name,
                              size: orderItem.size,
                              quantity: newQuantity,
                              options: orderItem.options,
                              sugarLevel: orderItem.sugarLevel,
                              note: orderItem.note,
                              price: orderItem.price,
                              orderItemId: orderItem.orderItemId,
                              itemId: orderItem.itemId,
                            );
                            controller.calculateTotalAmount();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 115),
          ],
        ),
      ),
    );
  }
}
