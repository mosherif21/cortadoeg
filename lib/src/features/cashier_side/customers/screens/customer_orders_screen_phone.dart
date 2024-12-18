import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/customers/controllers/customers_screen_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/back_button.dart';
import '../../orders/components/order_widget.dart';

class CustomerOrdersScreenPhone extends StatelessWidget {
  const CustomerOrdersScreenPhone(
      {super.key, required this.controller, required this.customerId});
  final CustomersScreenController controller;
  final String customerId;
  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    final screenHeight = getScreenHeight(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: const RegularBackButton(padding: 0),
        centerTitle: true,
        title: AutoSizeText(
          'customerOrders'.tr,
          maxLines: 2,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
              iconPos: isLangEnglish() ? IconPosition.left : IconPosition.right,
              textStyle: const TextStyle(color: Colors.grey),
              failedIcon: const Icon(Icons.error, color: Colors.grey),
              completeIcon: const Icon(Icons.done, color: Colors.grey),
              idleIcon: const Icon(Icons.arrow_downward, color: Colors.grey),
              releaseIcon: const Icon(Icons.refresh, color: Colors.grey),
            ),
            controller: controller.customerOrdersRefreshController,
            onRefresh: () => controller.onCustomerOrdersRefresh(),
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
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 5.0),
                      AutoSizeText(
                        'noOrdersCustomerBody'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                        maxLines: 2,
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: controller.loadingCustomerOrders.value
                        ? 10
                        : controller.customerOrders.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        columnCount: 1,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: controller.loadingCustomerOrders.value
                                ? const LoadingOrderWidget()
                                : Obx(
                                    () => OrderWidget(
                                      orderModel:
                                          controller.customerOrders[index],
                                      isChosen: false,
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
    );
  }
}
