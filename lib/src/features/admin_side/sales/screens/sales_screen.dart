import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/general_functions.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../components/general_sales_card.dart';
import '../controllers/sales_screen_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(SalesScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'salesOverview'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: screenType.isPhone
            ? Column(
                children: [
                  Align(
                    alignment: isLangEnglish()
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Obx(
                      () => SizedBox(
                        width: controller.dateRangeOptions.keys.length > 6
                            ? controller.dateRangeOptions.keys
                                    .toList()
                                    .elementAt(
                                        controller.currentSelectedDate.value)
                                    .contains('-')
                                ? screenType.isPhone
                                    ? 330
                                    : 300
                                : 190
                            : 180,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'selectDate'.tr,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: controller.dateRangeOptions.keys
                                .toList()
                                .map(
                                  (String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Container(
                                      constraints: screenType.isPhone &&
                                              controller.currentSelectedDate
                                                      .value ==
                                                  6
                                          ? const BoxConstraints(maxWidth: 300)
                                          : null,
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        item,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            value: controller.dateRangeOptions.keys
                                .toList()
                                .elementAt(
                                    controller.currentSelectedDate.value),
                            onChanged: (key) => key != null
                                ? controller.applyPredefinedDateRange(
                                    key,
                                    context,
                                    controller.dateRangeOptions.keys
                                        .toList()
                                        .indexOf(key))
                                : controller.applyPredefinedDateRange(
                                    'today'.tr, context, 0),
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 300,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      header: ClassicHeader(
                        completeDuration: const Duration(milliseconds: 0),
                        releaseText: 'releaseToRefresh'.tr,
                        refreshingText: 'refreshing'.tr,
                        idleText: 'pullToRefresh'.tr,
                        completeText: 'refreshCompleted'.tr,
                        iconPos: isLangEnglish()
                            ? IconPosition.left
                            : IconPosition.right,
                      ),
                      controller: controller.salesRefreshController,
                      onRefresh: () => controller.onRefresh(),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Obx(
                            () => GeneralReportsCard(
                              backgroundColor:
                                  const Color.fromRGBO(255, 245, 235, 1),
                              iconColor: const Color.fromRGBO(250, 179, 78, 1),
                              iconBackgroundColor:
                                  const Color.fromRGBO(255, 237, 213, 1),
                              amount:
                                  '${SalesScreenController.instance.totalRevenue.value.toStringAsFixed(2)} EGP',
                              subtitle: 'totalRevenue'.tr,
                              percentageTitle:
                                  controller.lastPeriodString.value,
                              percentage:
                                  '${SalesScreenController.instance.revenueChangePercentage.value.toStringAsFixed(1)}%',
                              increase: SalesScreenController
                                      .instance.revenueChangePercentage.value >=
                                  0,
                              icon: Icons.monetization_on_outlined,
                              loading: controller.loadingSales.value,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => GeneralReportsCard(
                              backgroundColor:
                                  const Color.fromRGBO(242, 238, 255, 1),
                              iconColor: const Color.fromRGBO(149, 111, 255, 1),
                              iconBackgroundColor:
                                  const Color.fromRGBO(226, 213, 255, 1),
                              amount:
                                  '${SalesScreenController.instance.totalOrders.value}',
                              subtitle: 'totalOrders'.tr,
                              percentageTitle:
                                  controller.lastPeriodString.value,
                              percentage:
                                  '${SalesScreenController.instance.ordersChangePercentage.value.toStringAsFixed(1)}%',
                              increase: SalesScreenController
                                      .instance.ordersChangePercentage.value >=
                                  0,
                              icon: FontAwesomeIcons.listUl,
                              loading: controller.loadingSales.value,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => GeneralReportsCard(
                              backgroundColor:
                                  const Color.fromRGBO(229, 250, 251, 1),
                              iconColor: const Color.fromRGBO(41, 207, 219, 1),
                              iconBackgroundColor:
                                  const Color.fromRGBO(211, 249, 250, 1),
                              amount:
                                  '${SalesScreenController.instance.totalCustomers.value}',
                              subtitle: 'totalCustomers'.tr,
                              percentageTitle:
                                  controller.lastPeriodString.value,
                              percentage:
                                  '${SalesScreenController.instance.customersChangePercentage.value.toStringAsFixed(1)}%',
                              increase: SalesScreenController.instance
                                      .customersChangePercentage.value >=
                                  0,
                              icon: Icons.people_rounded,
                              loading: controller.loadingSales.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
