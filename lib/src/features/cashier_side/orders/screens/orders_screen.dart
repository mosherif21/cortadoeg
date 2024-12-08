import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/orders_screen_item_widget.dart';
import '../controllers/orders_controller.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(OrdersController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenPagesAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'ordersHistory'.tr,
                unreadNotification: true,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: CustomDropdown<String>(
                          initialItem: 'allOrders'.tr,
                          items: [
                            'allOrders'.tr,
                            'active'.tr,
                            'completed'.tr,
                            'canceled'.tr,
                            'returned'.tr,
                          ],
                          onChanged: controller.onOrderStatusChanged,
                        ),
                      ),
                      Obx(
                        () => SizedBox(
                          width: controller.dateRangeOptions.keys.length > 6
                              ? controller.currentSelectedDate.contains('-')
                                  ? 280
                                  : 170
                              : 150,
                          child: CustomDropdown<String>(
                            items: controller.dateRangeOptions.keys.toList(),
                            controller: controller.dateSelectController,
                            onChanged: (key) => controller
                                .applyPredefinedDateRange(key, context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: RefreshConfiguration(
                        headerTriggerDistance: 60,
                        maxOverScrollExtent: 20,
                        enableLoadingWhenFailed: true,
                        hideFooterWhenNotFull: true,
                        child: SmartRefresher(
                          enablePullDown: true,
                          header: ClassicHeader(
                            completeDuration: const Duration(milliseconds: 0),
                            releaseText: 'releaseToRefresh'.tr,
                            refreshingText: 'refreshing'.tr,
                            idleText: 'pullToRefresh'.tr,
                            completeText: 'refreshCompleted'.tr,
                            iconPos: isLangEnglish()
                                ? IconPosition.left
                                : IconPosition.right,
                            textStyle: const TextStyle(color: Colors.grey),
                            failedIcon:
                                const Icon(Icons.error, color: Colors.grey),
                            completeIcon:
                                const Icon(Icons.done, color: Colors.grey),
                            idleIcon: const Icon(Icons.arrow_downward,
                                color: Colors.grey),
                            releaseIcon:
                                const Icon(Icons.refresh, color: Colors.grey),
                          ),
                          controller: controller.ordersRefreshController,
                          onRefresh: () => controller.onRefresh(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: AnimationLimiter(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  const double itemWidth = 220.0;
                                  const double itemHeight = 90.0;
                                  final crossAxisCount =
                                      (constraints.maxWidth / (itemWidth + 20))
                                          .floor();
                                  return Obx(
                                    () => GridView.builder(
                                      physics: const ScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 15,
                                        childAspectRatio:
                                            itemWidth / itemHeight,
                                      ),
                                      itemCount: controller.loadingOrders.value
                                          ? 20
                                          : controller.ordersList.length,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredGrid(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          columnCount: crossAxisCount,
                                          child: ScaleAnimation(
                                            child: FadeInAnimation(
                                              child: SizedBox(
                                                width: itemWidth,
                                                height: itemHeight,
                                                child: controller
                                                        .loadingOrders.value
                                                    ? const LoadingOrderWidget()
                                                    : Obx(
                                                        () => OrderWidget(
                                                          orderModel: controller
                                                                  .ordersList[
                                                              index],
                                                          isChosen: controller
                                                                          .ordersList[
                                                                      index] ==
                                                                  controller
                                                                      .currentChosenOrder
                                                                      .value
                                                              ? true
                                                              : false,
                                                          onTap: () =>
                                                              controller
                                                                  .onOrderTap(
                                                            chosenIndex: index,
                                                            isPhone: screenType
                                                                .isPhone,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.currentChosenOrder.value != null
                  ? Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200, //New
                              blurRadius: 10,
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
                                  child: Text(
                                    controller.currentChosenOrder.value!
                                            .customerName ??
                                        'guest'.tr,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
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
                                    itemCount: controller
                                        .currentChosenOrder.value!.items.length,
                                    itemBuilder: (context, index) {
                                      return OrdersScreenItemWidget(
                                          orderItemModel: controller
                                              .currentChosenOrder
                                              .value!
                                              .items[index]);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
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
                                              '\$${controller.currentChosenOrder.value!.subtotalAmount.toStringAsFixed(2)}',
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
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
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
                                              onTap: () {},
                                              child: Text(
                                                '-\$${controller.currentChosenOrder.value!.discountAmount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
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
                                              '\$${controller.currentChosenOrder.value!.taxTotalAmount.toStringAsFixed(2)}',
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
                                              '\$${controller.currentChosenOrder.value!.totalAmount.toStringAsFixed(2)}',
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
                                      icon: Icons.refresh,
                                      iconColor: Colors.white,
                                      text: 'reopen'.tr,
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
                                      icon: Icons.print_outlined,
                                      iconColor: Colors.white,
                                      text: 'print'.tr,
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
            ),
          ],
        ),
      ),
    );
  }
}
