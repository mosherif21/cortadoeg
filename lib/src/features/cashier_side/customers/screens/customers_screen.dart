import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../../orders/components/models.dart';
import '../../orders/components/order_widget.dart';
import '../../orders/components/orders_screen_item_widget.dart';
import '../controllers/customers_screen_controller.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(CustomersScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenPagesAppbar(
                appBarTitle: 'customers'.tr,
                unreadNotification: true,
                isPhone: screenType.isPhone,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: screenType.isPhone
            ? StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: Column(
                  children: [
                    AnimSearchAppBar(
                      hintStyle: const TextStyle(fontSize: 14),
                      keyboardType: TextInputType.text,
                      cancelButtonTextStyle:
                          const TextStyle(color: Colors.black87),
                      cancelButtonText: 'cancel'.tr,
                      hintText: 'searchCustomersHint'.tr,
                      onChanged: controller.onCustomerSearch,
                      backgroundColor: Colors.white,
                      appBar: const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Obx(
                        () => controller.loadingCustomers.value
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return loadingCustomerTile();
                                },
                              )
                            : RefreshConfiguration(
                                headerTriggerDistance: 60,
                                maxOverScrollExtent: 20,
                                enableLoadingWhenFailed: true,
                                hideFooterWhenNotFull: true,
                                child: SmartRefresher(
                                  enablePullDown: true,
                                  header: ClassicHeader(
                                    completeDuration:
                                        const Duration(milliseconds: 0),
                                    releaseText: 'releaseToRefresh'.tr,
                                    refreshingText: 'refreshing'.tr,
                                    idleText: 'pullToRefresh'.tr,
                                    completeText: 'refreshCompleted'.tr,
                                    iconPos: isLangEnglish()
                                        ? IconPosition.left
                                        : IconPosition.right,
                                    textStyle:
                                        const TextStyle(color: Colors.grey),
                                    failedIcon: const Icon(Icons.error,
                                        color: Colors.grey),
                                    completeIcon: const Icon(Icons.done,
                                        color: Colors.grey),
                                    idleIcon: const Icon(Icons.arrow_downward,
                                        color: Colors.grey),
                                    releaseIcon: const Icon(Icons.refresh,
                                        color: Colors.grey),
                                  ),
                                  controller:
                                      controller.customersRefreshController,
                                  onRefresh: () =>
                                      controller.onCustomersRefresh(),
                                  child: controller.customersList.isNotEmpty
                                      ? ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: controller
                                                  .filteredCustomers.length +
                                              1,
                                          itemBuilder: (context, index) {
                                            return index == 0
                                                ? addCustomerTile(
                                                    controller: controller,
                                                    context: context)
                                                : Obx(
                                                    () => customerTile(
                                                      customerModel: controller
                                                              .filteredCustomers[
                                                          index - 1],
                                                      onTap: () => controller
                                                          .onCustomerTap(
                                                        index: index,
                                                        customerId: controller
                                                            .filteredCustomers[
                                                                index - 1]
                                                            .customerId,
                                                        isPhone:
                                                            screenType.isPhone,
                                                      ),
                                                      onEditTap: () =>
                                                          controller
                                                              .onEditPress(
                                                        context: context,
                                                        customerModel: controller
                                                                .filteredCustomers[
                                                            index - 1],
                                                        index: index - 1,
                                                        isPhone:
                                                            screenType.isPhone,
                                                      ),
                                                      onDeleteTap: () =>
                                                          controller
                                                              .onDeleteTap(
                                                        customerModel: controller
                                                                .filteredCustomers[
                                                            index - 1],
                                                        index: index,
                                                        isPhone:
                                                            screenType.isPhone,
                                                      ),
                                                      chosen: controller
                                                              .chosenCustomerIndex
                                                              .value ==
                                                          index,
                                                    ),
                                                  );
                                          },
                                        )
                                      : Column(
                                          children: [
                                            addCustomerTile(
                                                controller: controller,
                                                context: context),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: noCustomerWidget(
                                                    screenHeight: screenHeight),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300, //New
                                      blurRadius: 5.0,
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: StretchingOverscrollIndicator(
                                  axisDirection: AxisDirection.down,
                                  child: Column(
                                    children: [
                                      AnimSearchAppBar(
                                        hintStyle:
                                            const TextStyle(fontSize: 14),
                                        keyboardType: TextInputType.text,
                                        cancelButtonTextStyle: const TextStyle(
                                            color: Colors.black87),
                                        cancelButtonText: 'cancel'.tr,
                                        hintText: 'searchCustomersHint'.tr,
                                        onChanged: controller.onCustomerSearch,
                                        backgroundColor: Colors.white,
                                        appBar: const SizedBox.shrink(),
                                      ),
                                      Expanded(
                                        child: Obx(
                                          () => controller
                                                  .loadingCustomers.value
                                              ? ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: 10,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return loadingCustomerTile();
                                                  },
                                                )
                                              : RefreshConfiguration(
                                                  headerTriggerDistance: 60,
                                                  maxOverScrollExtent: 20,
                                                  enableLoadingWhenFailed: true,
                                                  hideFooterWhenNotFull: true,
                                                  child: SmartRefresher(
                                                    enablePullDown: true,
                                                    header: ClassicHeader(
                                                      completeDuration:
                                                          const Duration(
                                                              milliseconds: 0),
                                                      releaseText:
                                                          'releaseToRefresh'.tr,
                                                      refreshingText:
                                                          'refreshing'.tr,
                                                      idleText:
                                                          'pullToRefresh'.tr,
                                                      completeText:
                                                          'refreshCompleted'.tr,
                                                      iconPos: isLangEnglish()
                                                          ? IconPosition.left
                                                          : IconPosition.right,
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                      failedIcon: const Icon(
                                                          Icons.error,
                                                          color: Colors.grey),
                                                      completeIcon: const Icon(
                                                          Icons.done,
                                                          color: Colors.grey),
                                                      idleIcon: const Icon(
                                                          Icons.arrow_downward,
                                                          color: Colors.grey),
                                                      releaseIcon: const Icon(
                                                          Icons.refresh,
                                                          color: Colors.grey),
                                                    ),
                                                    controller: controller
                                                        .customersRefreshController,
                                                    onRefresh: () => controller
                                                        .onCustomersRefresh(),
                                                    child:
                                                        controller.customersList
                                                                .isNotEmpty
                                                            ? ListView.builder(
                                                                scrollDirection:
                                                                    Axis.vertical,
                                                                itemCount: controller
                                                                        .filteredCustomers
                                                                        .length +
                                                                    1,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return index ==
                                                                          0
                                                                      ? addCustomerTile(
                                                                          controller:
                                                                              controller,
                                                                          context:
                                                                              context)
                                                                      : customerTile(
                                                                          customerModel:
                                                                              controller.filteredCustomers[index - 1],
                                                                          onTap: () =>
                                                                              controller.onCustomerTap(
                                                                            index:
                                                                                index,
                                                                            customerId:
                                                                                controller.filteredCustomers[index - 1].customerId,
                                                                            isPhone:
                                                                                screenType.isPhone,
                                                                          ),
                                                                          onEditTap: () =>
                                                                              controller.onEditPress(
                                                                            context:
                                                                                context,
                                                                            customerModel:
                                                                                controller.filteredCustomers[index - 1],
                                                                            index:
                                                                                index - 1,
                                                                            isPhone:
                                                                                screenType.isPhone,
                                                                          ),
                                                                          onDeleteTap: () =>
                                                                              controller.onDeleteTap(
                                                                            customerModel:
                                                                                controller.filteredCustomers[index - 1],
                                                                            index:
                                                                                index,
                                                                            isPhone:
                                                                                screenType.isPhone,
                                                                          ),
                                                                          chosen:
                                                                              controller.chosenCustomerIndex.value == index,
                                                                        );
                                                                },
                                                              )
                                                            : Column(
                                                                children: [
                                                                  addCustomerTile(
                                                                      controller:
                                                                          controller,
                                                                      context:
                                                                          context),
                                                                  Expanded(
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child: noCustomerWidget(
                                                                          screenHeight:
                                                                              screenHeight),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Obx(
                              () => controller.chosenCustomerIndex.value != 0
                                  ? RefreshConfiguration(
                                      headerTriggerDistance: 60,
                                      maxOverScrollExtent: 20,
                                      enableLoadingWhenFailed: true,
                                      hideFooterWhenNotFull: true,
                                      child: SmartRefresher(
                                        enablePullDown: true,
                                        header: ClassicHeader(
                                          completeDuration:
                                              const Duration(milliseconds: 0),
                                          releaseText: 'releaseToRefresh'.tr,
                                          refreshingText: 'refreshing'.tr,
                                          idleText: 'pullToRefresh'.tr,
                                          completeText: 'refreshCompleted'.tr,
                                          iconPos: isLangEnglish()
                                              ? IconPosition.left
                                              : IconPosition.right,
                                          textStyle: const TextStyle(
                                              color: Colors.grey),
                                          failedIcon: const Icon(Icons.error,
                                              color: Colors.grey),
                                          completeIcon: const Icon(Icons.done,
                                              color: Colors.grey),
                                          idleIcon: const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.grey),
                                          releaseIcon: const Icon(Icons.refresh,
                                              color: Colors.grey),
                                        ),
                                        controller: controller
                                            .customerOrdersRefreshController,
                                        onRefresh: () => controller
                                            .onCustomerOrdersRefresh(),
                                        child: controller.customerOrders.isEmpty
                                            ? Column(
                                                children: [
                                                  Lottie.asset(
                                                    kNoOrdersAnim,
                                                    fit: BoxFit.contain,
                                                    height: screenHeight * 0.5,
                                                  ),
                                                  AutoSizeText(
                                                    'noOrdersCustomerTitle'.tr,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    maxLines: 2,
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                  AutoSizeText(
                                                    'noOrdersCustomerBody'.tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    maxLines: 2,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 30),
                                                      child: AnimationLimiter(
                                                        child: Obx(
                                                          () =>
                                                              GridView.builder(
                                                            physics:
                                                                const ScrollPhysics(),
                                                            shrinkWrap: true,
                                                            gridDelegate:
                                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  controller.currentChosenOrder
                                                                              .value !=
                                                                          null
                                                                      ? 1
                                                                      : 2,
                                                              mainAxisSpacing:
                                                                  15,
                                                              crossAxisSpacing:
                                                                  15,
                                                              childAspectRatio:
                                                                  2.5,
                                                            ),
                                                            itemCount: controller
                                                                    .loadingCustomerOrders
                                                                    .value
                                                                ? 20
                                                                : controller
                                                                    .customerOrders
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return AnimationConfiguration
                                                                  .staggeredGrid(
                                                                position: index,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                columnCount:
                                                                    controller.currentChosenOrder.value !=
                                                                            null
                                                                        ? 1
                                                                        : 2,
                                                                child:
                                                                    ScaleAnimation(
                                                                  child:
                                                                      FadeInAnimation(
                                                                    child: controller
                                                                            .loadingCustomerOrders
                                                                            .value
                                                                        ? const LoadingOrderWidget()
                                                                        : Obx(
                                                                            () =>
                                                                                OrderWidget(
                                                                              orderModel: controller.customerOrders[index],
                                                                              isChosen: controller.customerOrders[index] == controller.currentChosenOrder.value ? true : false,
                                                                              onTap: () => controller.onOrderTap(
                                                                                chosenIndex: index,
                                                                                isPhone: screenType.isPhone,
                                                                              ),
                                                                            ),
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
                                                  Obx(
                                                    () => controller
                                                                .currentChosenOrder
                                                                .value !=
                                                            null
                                                        ? Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            15),
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200, //New
                                                                      blurRadius:
                                                                          10,
                                                                    )
                                                                  ],
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        15),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            'orderNumber'.trParams({
                                                                              'number': controller.currentChosenOrder.value!.orderNumber.toString()
                                                                            }),
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 5),
                                                                          Text(
                                                                            getOrderTime(controller.currentChosenOrder.value!.timestamp.toDate()),
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.w800,
                                                                              fontSize: 15,
                                                                              color: Colors.grey.shade600,
                                                                            ),
                                                                          ),
                                                                          if (controller.currentChosenOrder.value!.timestamp.toDate().isBefore(DateTime(
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
                                                                                fontSize: 15,
                                                                                color: Colors.grey.shade600,
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            10),
                                                                    Obx(
                                                                      () =>
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10),
                                                                        constraints:
                                                                            const BoxConstraints(maxWidth: 250),
                                                                        child:
                                                                            Text(
                                                                          controller.currentChosenOrder.value!.customerName ??
                                                                              'guest'.tr,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            5),
                                                                    const SectionDivider(),
                                                                    const SizedBox(
                                                                        height:
                                                                            5),
                                                                    Expanded(
                                                                      child:
                                                                          StretchingOverscrollIndicator(
                                                                        axisDirection:
                                                                            AxisDirection.down,
                                                                        child: ListView
                                                                            .builder(
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          itemCount: controller
                                                                              .currentChosenOrder
                                                                              .value!
                                                                              .items
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            return OrdersScreenItemWidget(orderItemModel: controller.currentChosenOrder.value!.items[index]);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            10),
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade100,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              20),
                                                                      child:
                                                                          Obx(
                                                                        () =>
                                                                            Column(
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
                                                                              padding: const EdgeInsets.only(left: 20, right: 20),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                    const SizedBox(
                                                                        height:
                                                                            20),
                                                                    controller.currentChosenOrder.value!.status ==
                                                                            OrderStatus
                                                                                .complete
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
                                                                                      onClick: () => controller.returnOrderTap(),
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
                                                                                      onClick: () => controller.onReopenOrderTap(isPhone: screenType.isPhone),
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
                                                                                onClick: () => controller.printOrderTap(),
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
                                                                                          icon: Icons.check_circle,
                                                                                          iconColor: Colors.white,
                                                                                          text: 'complete'.tr,
                                                                                          onClick: () => controller.completeOrderTap(),
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
                                                                                          onClick: () => controller.onReopenOrderTap(isPhone: screenType.isPhone),
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
                                                                                    onClick: () => controller.printOrderTap(),
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
                                                                                      onClick: () => controller.onReopenOrderTap(isPhone: screenType.isPhone),
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
                                                                                      onClick: () => controller.printOrderTap(),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Lottie.asset(
                                          kChooseCustomerAnim,
                                          fit: BoxFit.contain,
                                          height: screenHeight * 0.5,
                                        ),
                                        AutoSizeText(
                                          'chooseCustomerViewOrdersTitle'.tr,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 5.0),
                                        AutoSizeText(
                                          'chooseCustomerViewOrdersBody'.tr,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
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

  Widget noCustomerWidget({
    required double screenHeight,
  }) {
    return Column(
      children: [
        Lottie.asset(
          kNoCustomersAnim,
          fit: BoxFit.contain,
          height: screenHeight * 0.35,
        ),
        AutoSizeText(
          'noCustomersTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noCustomerBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget addCustomerTile({
    required CustomersScreenController controller,
    required BuildContext context,
  }) {
    return ExpansionTileCard(
      onExpansionChanged: (extendStatus) {
        controller.extended.value = extendStatus;
      },
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      expansionKey: controller.key0,
      elevation: 0,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      isHasTrailing: false,
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: false,
      isHideSubtitleOnExpanded: true,
      title: Obx(
        () => Row(
          children: [
            Icon(
              controller.extended.value ? Icons.remove : Icons.add_rounded,
              size: 25,
              color: Colors.black54,
            ),
            const SizedBox(width: 10),
            Text(
              controller.extended.value ? 'cancel'.tr : 'addCustomer'.tr,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
      ),
      children: [_buildChildren(controller: controller)],
    );
  }

  Widget _buildChildren({required CustomersScreenController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'customerInformation'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  controller: controller.nameTextController,
                  keyboardType: TextInputType.text,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'fullName'.tr,
                    hintText: 'enterFullName'.tr,
                  ),
                  validator: textNotEmpty,
                ),
                const SizedBox(height: 10),
                intl.IntlPhoneField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    labelStyle: const TextStyle(color: Colors.black),
                    labelText: 'phoneLabel'.tr,
                    hintText: 'phoneFieldLabel'.tr,
                  ),
                  initialCountryCode: 'EG',
                  invalidNumberMessage: 'invalidNumberMsg'.tr,
                  countries: const [
                    Country(
                      name: "Egypt",
                      nameTranslations: {
                        "en": "Egypt",
                        "ar": "مصر",
                      },
                      flag: "🇪🇬",
                      code: "EG",
                      dialCode: "20",
                      minLength: 10,
                      maxLength: 10,
                    ),
                  ],
                  pickerDialogStyle: PickerDialogStyle(
                    searchFieldInputDecoration:
                        InputDecoration(hintText: 'searchCountry'.tr),
                  ),
                  onChanged: (phone) {
                    controller.number.value = phone.completeNumber;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.percentageChosen.value = false;
                    },
                    style: ElevatedButton.styleFrom(
                      overlayColor: Colors.grey,
                      backgroundColor: controller.percentageChosen.value
                          ? Colors.grey.shade200
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.attach_money_rounded,
                      color: controller.percentageChosen.value
                          ? Colors.black54
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.percentageChosen.value = true;
                    },
                    style: ElevatedButton.styleFrom(
                      overlayColor: Colors.grey,
                      backgroundColor: controller.percentageChosen.value
                          ? Colors.black
                          : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.percent_rounded,
                      color: controller.percentageChosen.value
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    controller: controller.discountTextController,
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
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.addCustomerPress(isPhone: true),
              style: ElevatedButton.styleFrom(
                overlayColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.black,
              ),
              child: Text(
                'add'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customerTile(
      {required CustomerModel customerModel,
      required bool chosen,
      required Function onTap,
      required Function onEditTap,
      required Function onDeleteTap}) {
    final GlobalKey key0 = GlobalKey();
    return Slidable(
      useTextDirection: false,
      key: key0,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            onPressed: (context) => onEditTap(),
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit,
          ),
          SlidableAction(
            onPressed: (context) => onDeleteTap(),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_outlined,
          ),
        ],
      ),
      child: Material(
        color: chosen ? Colors.black : Colors.white,
        child: InkWell(
          splashFactory: InkSparkle.splashFactory,
          onTap: chosen ? null : () => onTap(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: chosen ? Colors.white : Colors.black,
                  child: Text(
                    customerModel.name[0].toUpperCase(),
                    style: TextStyle(
                        color: chosen ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  customerModel.name,
                  style: TextStyle(
                    color: chosen ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadingCustomerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              height: 30,
              width: 150,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
