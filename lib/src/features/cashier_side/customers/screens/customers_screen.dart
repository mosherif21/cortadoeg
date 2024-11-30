import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../../orders/components/models.dart';
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
        child: Column(
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
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300, //New
                                blurRadius: 5.0,
                              )
                            ],
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: StretchingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            child: Column(
                              children: [
                                AnimSearchAppBar(
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
                                                    const Duration(
                                                        milliseconds: 0),
                                                releaseText:
                                                    'releaseToRefresh'.tr,
                                                refreshingText: 'refreshing'.tr,
                                                idleText: 'pullToRefresh'.tr,
                                                completeText:
                                                    'refreshCompleted'.tr,
                                                iconPos: isLangEnglish()
                                                    ? IconPosition.left
                                                    : IconPosition.right,
                                                textStyle: const TextStyle(
                                                    color: Colors.grey),
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
                                                              (context, index) {
                                                            return index == 0
                                                                ? addCustomerTile(
                                                                    controller:
                                                                        controller,
                                                                    context:
                                                                        context)
                                                                : Obx(
                                                                    () =>
                                                                        customerTile(
                                                                      customerModel: controller
                                                                              .filteredCustomers[
                                                                          index -
                                                                              1],
                                                                      onTap: () => controller.onCustomerTap(
                                                                          index:
                                                                              index,
                                                                          customerId: controller
                                                                              .filteredCustomers[index - 1]
                                                                              .customerId),
                                                                      onEditTap: () => controller.onEditPress(
                                                                          context:
                                                                              context,
                                                                          customerModel: controller.filteredCustomers[index -
                                                                              1],
                                                                          index:
                                                                              index - 1),
                                                                      onDeleteTap:
                                                                          () =>
                                                                              controller.onDeleteTap(
                                                                        customerModel:
                                                                            controller.filteredCustomers[index -
                                                                                1],
                                                                        index:
                                                                            index,
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
                      child: Container(
                        color: Colors.white,
                        height: double.infinity,
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
                                    controller: controller
                                        .customerOrdersRefreshController,
                                    onRefresh: () =>
                                        controller.onCustomerOrdersRefresh(),
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
                                        : ListView.builder(
                                            itemCount: controller
                                                .customerOrders.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Text(controller
                                                  .customerOrders[index]
                                                  .orderId);
                                            },
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
    return GestureDetector(
      onTap: () => controller.onAddCustomerTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            const Icon(
              Icons.person_add,
              size: 25,
              color: Colors.black54,
            ),
            const SizedBox(width: 10),
            Text(
              'addCustomer'.tr,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
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
          onTap: () => onTap(),
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
              width: 250,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
