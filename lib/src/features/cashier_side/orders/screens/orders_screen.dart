import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../controllers/orders_controller.dart';
import 'order_screen.dart';

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
                      onChanged: (key) =>
                          controller.applyPredefinedDateRange(key, context),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => Expanded(
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
                        failedIcon: const Icon(Icons.error, color: Colors.grey),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimationLimiter(
                          child: GridView.count(
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            physics: const ScrollPhysics(),
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            children: List.generate(
                              controller.loadingOrders.value
                                  ? 10
                                  : controller.ordersList.length,
                              (int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 300),
                                  columnCount:
                                      // controller.orderItems.isEmpty
                                      //     ? 5
                                      //     :
                                      4,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: controller.loadingOrders.value
                                          ? const LoadingItem()
                                          : OrderWidget(
                                              orderModel:
                                                  controller.ordersList[index]),
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
