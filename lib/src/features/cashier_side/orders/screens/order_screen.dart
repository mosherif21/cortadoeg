import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../components/cart_item_widget.dart';
import '../components/discount_widget.dart';
import '../components/item_widget.dart';
import '../components/new_order_categories.dart';
import '../components/new_order_screen_appbar.dart';
import '../controllers/order_controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.orderModel});
  final OrderModel orderModel;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(OrderController(orderModel: orderModel));
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Obx(
        () => Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: SingleChildScrollView(
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              NewOrderScreenAppbar(
                                searchBarTextController:
                                    controller.searchBarTextController,
                                isTakeaway: orderModel.isTakeaway,
                                currentOrderId: orderModel.orderId,
                                tablesNo: orderModel.tableNumbers,
                                titleFontSize: 20,
                              ),
                              Obx(
                                () => CategoryMenu(
                                  categories: controller.categories,
                                  selectedCategory:
                                      controller.selectedCategory.value,
                                  onSelect: controller.onCategorySelect,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Obx(
                                () => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: AnimationLimiter(
                                    child: GridView.count(
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing:
                                          controller.orderItems.isEmpty
                                              ? 20
                                              : 20,
                                      physics: const ScrollPhysics(),
                                      crossAxisCount:
                                          controller.orderItems.isEmpty ? 5 : 4,
                                      shrinkWrap: true,
                                      children: List.generate(
                                        controller.selectedItems.length,
                                        (int index) {
                                          return AnimationConfiguration
                                              .staggeredGrid(
                                            position: index,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            columnCount: 5,
                                            child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                child: ItemCard(
                                                  imageUrl: controller
                                                      .selectedItems[index]
                                                      .imageUrl,
                                                  title: controller
                                                      .selectedItems[index]
                                                      .name,
                                                  price: controller
                                                      .selectedItems[index]
                                                      .sizes[0]
                                                      .price,
                                                  onSelected: () =>
                                                      controller.onItemSelected(
                                                          context,
                                                          index,
                                                          screenType.isPhone),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                controller.orderItems.isNotEmpty
                    ? Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200, //New
                                blurRadius: 5,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(15),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          controller.currentCustomerName.value,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      controller.currentCustomer != null
                                          ? IconTextElevatedButton(
                                              buttonColor: Colors.grey.shade100,
                                              textColor: Colors.black87,
                                              borderRadius: 10,
                                              elevation: 0,
                                              icon: Icons.close_rounded,
                                              iconColor: Colors.black87,
                                              text: 'removeCustomer'.tr,
                                              onClick: () =>
                                                  controller.onRemoveCustomer(),
                                            )
                                          : IconTextElevatedButton(
                                              buttonColor: Colors.grey.shade100,
                                              textColor: Colors.black87,
                                              borderRadius: 10,
                                              elevation: 0,
                                              icon: Icons.add_rounded,
                                              iconColor: Colors.black87,
                                              text: 'addCustomer'.tr,
                                              onClick: () => controller
                                                  .onCustomerChoose(context),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const SectionDivider(),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: StretchingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: controller.orderItems.length,
                                      itemBuilder: (context, index) {
                                        return CartItemWidget(
                                          orderItemModel:
                                              controller.orderItems[index],
                                          onEditTap: () =>
                                              controller.onEditItem(index,
                                                  context, screenType.isPhone),
                                          onDeleteTap: () =>
                                              controller.onDeleteItem(index),
                                          index: index,
                                          onDismissed: () =>
                                              controller.onDeleteItem(index),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      splashFactory: InkSparkle.splashFactory,
                                      overlayColor: Colors.grey,
                                    ),
                                    child: Obx(
                                      () => Text(
                                        controller.discountAmount.value > 0
                                            ? 'editDiscount'.tr
                                            : 'addDiscount'.tr,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15),
                                      ),
                                    ),
                                    onPressed: () => controller.addDiscount(),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'subtotal'.tr,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '\$${controller.orderSubtotal.value.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
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
                                                : controller.discountAmount
                                                            .value >
                                                        0
                                                    ? 2
                                                    : 20,
                                            right: isLangEnglish()
                                                ? controller.discountAmount
                                                            .value >
                                                        0
                                                    ? 2
                                                    : 20
                                                : 20,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'discountSales'.tr,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '-\$${controller.discountAmount.value.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (controller.discountAmount
                                                          .value >
                                                      0)
                                                    GestureDetector(
                                                      onTap: () => controller
                                                          .onCancelDiscount(),
                                                      child: const Icon(
                                                        size: 15,
                                                        Icons.cancel_rounded,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'totalSalesTax'.tr,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '\$${controller.orderTax.value.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'total'.tr,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                '\$${controller.orderTotal.value.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: IconTextElevatedButton(
                                        buttonColor: Colors.deepOrange,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.pause,
                                        iconColor: Colors.white,
                                        text: 'holdCart'.tr,
                                        onClick: () => Get.back(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: IconTextElevatedButton(
                                        buttonColor: Colors.green,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.payments_outlined,
                                        iconColor: Colors.white,
                                        text: 'charge'.tr,
                                        onClick: () {},
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            if (controller.addingDiscount.value)
              Positioned(
                bottom: 130,
                right: isLangEnglish() ? 330 : null,
                left: isLangEnglish() ? null : 330,
                child: DiscountWidget(
                  percentageChosen: controller.percentageChosen,
                  discountTextController: controller.discountTextController,
                  initialDiscountType: controller.discountType ?? 'percentage',
                  initialDiscountValue: controller.discountValue ?? 0,
                  onAddDiscount: controller.onAddDiscount,
                  onCancel: () {
                    controller.addingDiscount.value = false;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
