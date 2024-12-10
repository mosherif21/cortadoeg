import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/no_orders_widget.dart';
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
    final TextEditingController orderSearchTextController =
        TextEditingController();
    orderSearchTextController.addListener(() {
      controller.searchText = orderSearchTextController.text.trim();
      controller.onOrdersSearch();
    });
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
                          items: [
                            'active'.tr,
                            'allOrders'.tr,
                            'completed'.tr,
                            'canceled'.tr,
                            'returned'.tr,
                          ],
                          controller: controller.statusSelectController,
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
                  AnimSearchAppBar(
                    keyboardType: TextInputType.text,
                    cancelButtonTextStyle:
                        const TextStyle(color: Colors.black87),
                    cancelButtonText: 'cancel'.tr,
                    hintText: 'searchOrdersHint'.tr,
                    cSearch: orderSearchTextController,
                    backgroundColor: Colors.white,
                    appBar: const SizedBox.shrink(),
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
                                  const double itemWidth = 230.0;
                                  const double itemHeight = 90.0;
                                  final orderChosen =
                                      controller.currentChosenOrder.value !=
                                          null;
                                  final navBarExtended = MainScreenController
                                      .instance.navBarExtended.value;
                                  return Obx(
                                    () =>
                                        !controller.loadingOrders.value &&
                                                controller
                                                    .filteredOrdersList.isEmpty
                                            ? NoOrdersWidget(
                                                status: controller
                                                    .selectedStatus.value)
                                            : GridView.builder(
                                                physics: const ScrollPhysics(),
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: navBarExtended
                                                      ? orderChosen
                                                          ? 2
                                                          : 3
                                                      : orderChosen
                                                          ? 3
                                                          : 4,
                                                  mainAxisSpacing: 15,
                                                  crossAxisSpacing: 15,
                                                  childAspectRatio: 2.5,
                                                ),
                                                itemCount: controller
                                                        .loadingOrders.value
                                                    ? 20
                                                    : controller
                                                        .filteredOrdersList
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  return AnimationConfiguration
                                                      .staggeredGrid(
                                                    position: index,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    columnCount: navBarExtended
                                                        ? orderChosen
                                                            ? 2
                                                            : 3
                                                        : orderChosen
                                                            ? 3
                                                            : 4,
                                                    child: ScaleAnimation(
                                                      child: FadeInAnimation(
                                                        child: SizedBox(
                                                          width: itemWidth,
                                                          height: itemHeight,
                                                          child: controller
                                                                  .loadingOrders
                                                                  .value
                                                              ? const LoadingOrderWidget()
                                                              : Obx(
                                                                  () =>
                                                                      OrderWidget(
                                                                    orderModel:
                                                                        controller
                                                                            .filteredOrdersList[index],
                                                                    isChosen: controller.filteredOrdersList[index] ==
                                                                            controller.currentChosenOrder.value
                                                                        ? true
                                                                        : false,
                                                                    onTap: () =>
                                                                        controller
                                                                            .onOrderTap(
                                                                      chosenIndex:
                                                                          index,
                                                                      isPhone:
                                                                          screenType
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
                      flex: MainScreenController.instance.navBarExtended.value
                          ? 2
                          : 1,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'orderNumber'.trParams({
                                      'number': controller
                                          .currentChosenOrder.value!.orderNumber
                                          .toString()
                                    }),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    getOrderTime(controller
                                        .currentChosenOrder.value!.timestamp
                                        .toDate()),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (controller
                                      .currentChosenOrder.value!.timestamp
                                      .toDate()
                                      .isBefore(DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          0,
                                          0,
                                          0)))
                                    Text(
                                      ' ${getOrderDate(controller.currentChosenOrder.value!.timestamp.toDate())}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Obx(
                              () => Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                constraints:
                                    const BoxConstraints(maxWidth: 250),
                                child: Text(
                                  controller.currentChosenOrder.value!
                                          .customerName ??
                                      'guest'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                              padding: const EdgeInsets.symmetric(vertical: 20),
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
                                          Text(
                                            '-\$${controller.currentChosenOrder.value!.discountAmount.toStringAsFixed(2)}',
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
                            controller.currentChosenOrder.value!.status ==
                                    OrderStatus.complete
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: IconTextElevatedButton(
                                              buttonColor: Colors.amber,
                                              textColor: Colors.white,
                                              borderRadius: 10,
                                              elevation: 0,
                                              icon: Icons.assignment_return,
                                              iconColor: Colors.white,
                                              text: 'return'.tr,
                                              onClick: () =>
                                                  controller.returnOrderTap(),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: IconTextElevatedButton(
                                              buttonColor: Colors.deepOrange,
                                              textColor: Colors.white,
                                              borderRadius: 10,
                                              elevation: 0,
                                              icon: Icons.refresh,
                                              iconColor: Colors.white,
                                              text: 'reopen'.tr,
                                              onClick: () =>
                                                  controller.onReopenOrderTap(
                                                      isPhone:
                                                          screenType.isPhone),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      IconTextElevatedButton(
                                        buttonColor: Colors.green,
                                        textColor: Colors.white,
                                        borderRadius: 10,
                                        elevation: 0,
                                        icon: Icons.print_outlined,
                                        iconColor: Colors.white,
                                        text: 'printInvoice'.tr,
                                        onClick: () =>
                                            controller.printOrderTap(),
                                      ),
                                    ],
                                  )
                                : controller.currentChosenOrder.value!.status ==
                                        OrderStatus.returned
                                    ? Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: IconTextElevatedButton(
                                                  buttonColor: Colors.grey,
                                                  textColor: Colors.white,
                                                  borderRadius: 10,
                                                  elevation: 0,
                                                  icon: Icons.start_rounded,
                                                  iconColor: Colors.white,
                                                  text: 'complete'.tr,
                                                  onClick: () => controller
                                                      .completeOrderTap(),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: IconTextElevatedButton(
                                                  buttonColor:
                                                      Colors.deepOrange,
                                                  textColor: Colors.white,
                                                  borderRadius: 10,
                                                  elevation: 0,
                                                  icon: Icons.refresh,
                                                  iconColor: Colors.white,
                                                  text: 'reopen'.tr,
                                                  onClick: () => controller
                                                      .onReopenOrderTap(
                                                          isPhone: screenType
                                                              .isPhone),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          IconTextElevatedButton(
                                            buttonColor: Colors.green,
                                            textColor: Colors.white,
                                            borderRadius: 10,
                                            elevation: 0,
                                            icon: Icons.print_outlined,
                                            iconColor: Colors.white,
                                            text: 'printInvoice'.tr,
                                            onClick: () =>
                                                controller.printOrderTap(),
                                          ),
                                        ],
                                      )
                                    : Row(
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
                                              onClick: () =>
                                                  controller.onReopenOrderTap(
                                                      isPhone:
                                                          screenType.isPhone),
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
                                              onClick: () =>
                                                  controller.printOrderTap(),
                                            ),
                                          ),
                                        ],
                                      ),
                          ],
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
