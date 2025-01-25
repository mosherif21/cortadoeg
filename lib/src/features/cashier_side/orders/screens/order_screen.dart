import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../../admin_side/menu_items/screens/meni_items_screen.dart';
import '../components/cart_item_widget.dart';
import '../components/discount_widget.dart';
import '../components/item_widget.dart';
import '../components/new_order_categories.dart';
import '../controllers/order_controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.orderModel, this.tablesIds});
  final OrderModel orderModel;
  final List<String>? tablesIds;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller =
        Get.put(OrderController(orderModel: orderModel, tablesIds: tablesIds));
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
                  flex: 2,
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
                              AnimSearchAppBar(
                                keyboardType: TextInputType.text,
                                cancelButtonTextStyle:
                                    const TextStyle(color: Colors.black87),
                                cancelButtonText: 'cancel'.tr,
                                hintText: 'searchItemsHint'.tr,
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w600),
                                backgroundColor: Colors.grey.shade100,
                                onChanged: controller.onItemsSearch,
                                appBar: AppBar(
                                  elevation: 0,
                                  leading: const RegularBackButton(padding: 0),
                                  title: AutoSizeText(
                                    formatOrderDetails(
                                      isTakeaway: orderModel.isTakeaway,
                                      orderNumber:
                                          orderModel.orderNumber.toString(),
                                      tablesNo: orderModel.tableNumbers,
                                    ),
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade100,
                                  surfaceTintColor: Colors.grey.shade100,
                                ),
                              ),
                              Obx(
                                () => controller.loadingCategories.value
                                    ? const LoadingCategories()
                                    : CategoryMenu(
                                        categories: controller.categories,
                                        selectedCategory:
                                            controller.selectedCategory.value,
                                        onSelect: controller.onCategorySelect,
                                      ),
                              ),
                              const SizedBox(height: 5),
                              Obx(
                                () => !controller.loadingItems.value &&
                                        controller.filteredItems.isEmpty
                                    ? const Center(
                                        child: SingleChildScrollView(
                                            child: NoItemsFound()),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: AnimationLimiter(
                                          child: GridView.count(
                                            mainAxisSpacing: 20,
                                            crossAxisSpacing: 20,
                                            physics: const ScrollPhysics(),
                                            crossAxisCount:
                                                controller.orderItems.isEmpty
                                                    ? 5
                                                    : 3,
                                            shrinkWrap: true,
                                            children: List.generate(
                                              controller.loadingItems.value
                                                  ? 10
                                                  : controller
                                                      .filteredItems.length,
                                              (int index) {
                                                return AnimationConfiguration
                                                    .staggeredGrid(
                                                  position: index,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  columnCount: controller
                                                          .orderItems.isEmpty
                                                      ? 5
                                                      : 3,
                                                  child: ScaleAnimation(
                                                    child: FadeInAnimation(
                                                      child: controller
                                                              .loadingItems
                                                              .value
                                                          ? const LoadingItem()
                                                          : ItemCard(
                                                              imageUrl: controller
                                                                  .filteredItems[
                                                                      index]
                                                                  .imageUrl,
                                                              title: controller
                                                                  .filteredItems[
                                                                      index]
                                                                  .name,
                                                              price: controller
                                                                  .filteredItems[
                                                                      index]
                                                                  .sizes[0]
                                                                  .price,
                                                              onSelected: () =>
                                                                  controller.onItemSelected(
                                                                      context,
                                                                      index,
                                                                      screenType
                                                                          .isPhone),
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
                                  () => Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 80),
                                          child: Text(
                                            controller
                                                .currentCustomerName.value,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        controller.currentCustomerName.value !=
                                                'guest'.tr
                                            ? IconTextElevatedButton(
                                                buttonColor:
                                                    Colors.grey.shade100,
                                                textColor: Colors.black87,
                                                borderRadius: 10,
                                                elevation: 0,
                                                icon: Icons.close_rounded,
                                                iconColor: Colors.black87,
                                                text: 'removeCustomer'.tr,
                                                onClick: () => controller
                                                    .onRemoveCustomer(),
                                              )
                                            : IconTextElevatedButton(
                                                buttonColor:
                                                    Colors.grey.shade100,
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
                                              controller.onEditItemPress(index,
                                                  context, screenType.isPhone),
                                          onDeleteTap: () =>
                                              controller.onDeleteItem(
                                                  index,
                                                  context,
                                                  controller.orderItems[index]),
                                          onDismissed: () async {
                                            return await controller
                                                .onDeleteItem(
                                                    index,
                                                    context,
                                                    controller
                                                        .orderItems[index]);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        splashFactory: InkSparkle.splashFactory,
                                        overlayColor: Colors.grey,
                                      ),
                                      child: Obx(
                                        () => Text(
                                          controller.orderTax.value > 0
                                              ? 'removeVat'.tr
                                              : 'addVat'.tr,
                                          style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15),
                                        ),
                                      ),
                                      onPressed: () =>
                                          controller.orderTax.value > 0
                                              ? controller.removeTax()
                                              : controller.addTax(),
                                    ),
                                    TextButton(
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
                                  ],
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
                                                'EGP ${controller.orderSubtotal.value.toStringAsFixed(2)}',
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
                                                'EGP ${controller.orderTax.value.toStringAsFixed(2)}',
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
                                              GestureDetector(
                                                onTap: () => controller
                                                    .onCancelDiscount(),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '-EGP ${controller.discountAmount.value.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    if (controller
                                                            .discountAmount
                                                            .value >
                                                        0)
                                                      const Icon(
                                                        size: 15,
                                                        Icons.cancel_rounded,
                                                        color: Colors.grey,
                                                      )
                                                  ],
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
                                                'EGP ${controller.orderTotal.value.toStringAsFixed(2)}',
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
                                        buttonColor: Colors.red,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.close,
                                        iconColor: Colors.white,
                                        text: 'cancelOrder'.tr,
                                        onClick: () =>
                                            controller.onCancelOrderTap(
                                          isPhone: false,
                                          chargeScreen: false,
                                          context: context,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: IconTextElevatedButton(
                                        buttonColor: Colors.deepOrange,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.pause,
                                        iconColor: Colors.white,
                                        text: 'holdCart'.tr,
                                        onClick: () => Get.back(result: false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: IconTextElevatedButton(
                                        buttonColor: Colors.green,
                                        textColor: Colors.white,
                                        borderRadius: 15,
                                        elevation: 0,
                                        icon: Icons.print_outlined,
                                        iconColor: Colors.white,
                                        enabled:
                                            controller.orderItems.isNotEmpty,
                                        text: 'printInvoice'.tr,
                                        onClick: () => controller.printOrderTap(
                                            isPhone: true, context: context),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: IconTextElevatedButton(
                                        buttonColor: Colors.black,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.payments_outlined,
                                        iconColor: Colors.white,
                                        text: 'charge'.tr,
                                        onClick: () => controller.onChargeTap(
                                            isPhone: false, context: context),
                                      ),
                                    ),
                                  ],
                                ),
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

class LoadingItem extends StatelessWidget {
  const LoadingItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Container(
            height: 130,
            width: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: 100,
                  color: Colors.black,
                ),
                Container(
                  height: 20,
                  width: 40,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class LoadingCategories extends StatelessWidget {
  const LoadingCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 15),
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
