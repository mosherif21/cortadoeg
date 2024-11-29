import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../components/cart_item_widget_phone.dart';
import '../components/item_widget_phone.dart';
import '../components/models.dart';
import '../components/new_order_categories_phone.dart';
import '../components/new_order_screen_appbar.dart';
import '../controllers/order_controller.dart';
import 'charge_screen_phone.dart';

class OrderScreenPhone extends StatelessWidget {
  const OrderScreenPhone({super.key, required this.orderModel});
  final OrderModel orderModel;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(OrderController(orderModel: orderModel));
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: DraggableBottomSheet(
        minExtent: 105,
        useSafeArea: false,
        curve: Curves.easeIn,
        maxExtent: screenHeight * 0.6,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: Colors.grey.shade100,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 25, bottom: 25, left: 25, right: 25),
                            child: Obx(
                              () => Text(
                                controller.orderItems.length.toString(),
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: Obx(
                              () => IconTextElevatedButton(
                                buttonColor: Colors.black,
                                textColor: Colors.white,
                                borderRadius: 25,
                                fontSize: 18,
                                elevation: 0,
                                icon: Icons.shopping_cart,
                                iconColor: Colors.white,
                                text: 'checkOut'.tr,
                                enabled: controller.orderTotal.value > 0,
                                onClick: () => Get.to(
                                  () =>
                                      ChargeScreenPhone(controller: controller),
                                  transition: getPageTransition(),
                                ),
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
                'orderCart'.tr,
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                maxLines: 1,
              ),
              Expanded(
                child: Obx(
                  () => controller.orderItems.isNotEmpty
                      ? StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: controller.orderItems.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: CartItemWidgetPhone(
                                  orderItemModel: controller.orderItems[index],
                                  onEditTap: () => controller.onEditItemPress(
                                      index, context, screenType.isPhone),
                                  onDeleteTap: () => controller.onDeleteItem(
                                      index,
                                      context,
                                      controller.orderItems[index]),
                                  index: index,
                                  onDismissed: () async {
                                    return await controller.onDeleteItem(index,
                                        context, controller.orderItems[index]);
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  kEmptyCartAnim,
                                  fit: BoxFit.contain,
                                  height: screenHeight * 0.25,
                                ),
                                const SizedBox(height: 10),
                                AutoSizeText(
                                  'noItemsCart'.tr,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
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
                      borderRadius: 25,
                      fontSize: 20,
                      elevation: 0,
                      icon: Icons.shopping_cart,
                      iconColor: Colors.white,
                      enabled: controller.orderTotal.value > 0,
                      text:
                          '${'checkOut'.tr} | \$${controller.orderTotal.value.toStringAsFixed(2)}',
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
        backgroundWidget: StretchingOverscrollIndicator(
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
                      titleFontSize: 18,
                    ),
                    Obx(
                      () => controller.loadingCategories.value
                          ? const LoadingCategories()
                          : CategoryMenuPhone(
                              categories: controller.categories,
                              selectedCategory:
                                  controller.selectedCategory.value,
                              onSelect: controller.onCategorySelect,
                            ),
                    ),
                    const SizedBox(height: 5),
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimationLimiter(
                          child: GridView.count(
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            physics: const ScrollPhysics(),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: List.generate(
                              controller.loadingItems.value
                                  ? 10
                                  : controller.filteredItems.length,
                              (int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 300),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: controller.loadingItems.value
                                          ? const LoadingItem()
                                          : ItemCardPhone(
                                              imageUrl: controller
                                                      .filteredItems[index]
                                                      .imageUrl ??
                                                  kLogoImage,
                                              title: controller
                                                  .filteredItems[index].name,
                                              price: controller
                                                  .filteredItems[index]
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
                    const SizedBox(height: 125),
                  ],
                ),
              ),
            ),
          ),
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
      child: Container(
        height: 100,
        width: 180,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.grey,
        ),
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
        height: 130,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 15),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
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
