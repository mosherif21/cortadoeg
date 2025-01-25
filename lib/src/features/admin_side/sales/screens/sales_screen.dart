import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../components/general_sales_card.dart';
import '../components/orders_analytics_card.dart';
import '../components/sales_analytics_card.dart';
import '../components/sales_profit_card.dart';
import '../controllers/sales_screen_controller.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(SalesScreenController());
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 16);
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
        child: Column(
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
                              .elementAt(controller.currentSelectedDate.value)
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
                                        controller.currentSelectedDate.value ==
                                            6
                                    ? const BoxConstraints(maxWidth: 300)
                                    : null,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  item,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                          .elementAt(controller.currentSelectedDate.value),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                header: ClassicHeader(
                  completeDuration: const Duration(milliseconds: 0),
                  releaseText: 'releaseToRefresh'.tr,
                  refreshingText: 'refreshing'.tr,
                  idleText: 'pullToRefresh'.tr,
                  completeText: 'refreshCompleted'.tr,
                  iconPos:
                      isLangEnglish() ? IconPosition.left : IconPosition.right,
                ),
                controller: controller.salesRefreshController,
                onRefresh: () => controller.onRefresh(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: SingleChildScrollView(
                      child: Obx(
                        () => screenType.isPhone
                            ? Column(
                                children: [
                                  GeneralReportsCard(
                                    backgroundColor:
                                        const Color.fromRGBO(255, 245, 235, 1),
                                    iconColor:
                                        const Color.fromRGBO(250, 179, 78, 1),
                                    iconBackgroundColor:
                                        const Color.fromRGBO(255, 237, 213, 1),
                                    amount:
                                        '${controller.totalRevenue.value.toStringAsFixed(2)} EGP',
                                    subtitle: 'totalRevenue'.tr,
                                    percentageTitle:
                                        controller.lastPeriodString.value,
                                    percentage:
                                        '${controller.revenueChangePercentage.value.toStringAsFixed(1)}%',
                                    increase: controller
                                            .revenueChangePercentage.value >=
                                        0,
                                    icon: Icons.monetization_on_outlined,
                                    loading: controller.loadingSales.value,
                                  ),
                                  const SizedBox(height: 16),
                                  GeneralReportsCard(
                                    backgroundColor:
                                        const Color.fromRGBO(242, 238, 255, 1),
                                    iconColor:
                                        const Color.fromRGBO(149, 111, 255, 1),
                                    iconBackgroundColor:
                                        const Color.fromRGBO(226, 213, 255, 1),
                                    amount:
                                        controller.totalOrders.value.toString(),
                                    subtitle: 'totalOrders'.tr,
                                    percentageTitle:
                                        controller.lastPeriodString.value,
                                    percentage:
                                        '${controller.ordersChangePercentage.value.toStringAsFixed(1)}%',
                                    increase: controller
                                            .ordersChangePercentage.value >=
                                        0,
                                    icon: FontAwesomeIcons.listUl,
                                    loading: controller.loadingSales.value,
                                  ),
                                  const SizedBox(height: 16),
                                  GeneralReportsCard(
                                    backgroundColor:
                                        const Color.fromRGBO(229, 250, 251, 1),
                                    iconColor:
                                        const Color.fromRGBO(41, 207, 219, 1),
                                    iconBackgroundColor:
                                        const Color.fromRGBO(211, 249, 250, 1),
                                    amount: controller
                                        .totalRegularCustomerOrders.value
                                        .toString(),
                                    subtitle: 'regularCustomerOrders'.tr,
                                    percentageTitle:
                                        controller.lastPeriodString.value,
                                    percentage:
                                        '${controller.customersChangePercentage.value.toStringAsFixed(1)}%',
                                    increase: controller
                                            .customersChangePercentage.value >=
                                        0,
                                    icon: Icons.people_rounded,
                                    loading: controller.loadingSales.value,
                                  ),
                                  const SizedBox(height: 16),
                                  SalesProfitCard(
                                    totalProfit:
                                        '${controller.totalProfit.value.toStringAsFixed(2)} EGP',
                                    totalCostPrice:
                                        '${controller.totalCostPrice.value.toStringAsFixed(2)} EGP',
                                    percentage:
                                        '${controller.customersChangePercentage.value.toStringAsFixed(1)}%',
                                    percentageTitle:
                                        controller.lastPeriodString.value,
                                    increase: controller
                                            .customersChangePercentage.value >=
                                        0,
                                    loading: controller.loadingSales.value,
                                  ),
                                  const SizedBox(height: 16),
                                  SalesAnalyticsCard(
                                    completePercent: controller
                                        .completeOrderPercentage.value,
                                    returnPercent: controller
                                        .returnedOrderPercentage.value,
                                    canceledPercent: controller
                                        .canceledOrderPercentage.value,
                                    isPhone: screenType.isPhone,
                                  ),
                                  const SizedBox(height: 16),
                                  OrdersAnalyticsCard(
                                    dineInPercent:
                                        controller.dineInOrdersPercentage.value,
                                    takeawayPercent: controller
                                        .takeawayOrdersPercentage.value,
                                    isPhone: screenType.isPhone,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'topSoldItems'.tr,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 24,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: screenHeight * 0.6,
                                    child: AsyncPaginatedDataTable2(
                                      key: controller.itemsTableKey,
                                      rowsPerPage: controller.rowsPerPage,
                                      showCheckboxColumn: false,
                                      isVerticalScrollBarVisible: true,
                                      initialFirstRowIndex: 0,
                                      isHorizontalScrollBarVisible: true,
                                      onSelectAll: (_) {},
                                      wrapInCard: true,
                                      minWidth: 1100,
                                      headingRowColor:
                                          const WidgetStatePropertyAll(
                                              Colors.white),
                                      empty: const SizedBox.shrink(),
                                      loading: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Lottie.asset(
                                          kLoadingWalkingCoffeeAnim,
                                          height: screenHeight * 0.5,
                                        ),
                                      ),
                                      columns: [
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('itemName'.tr,
                                                  style: textStyle)),
                                          tooltip: 'itemName'.tr,
                                          fixedWidth: 140,
                                          size: ColumnSize.L,
                                        ),
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('orders'.tr,
                                                  style: textStyle)),
                                          tooltip: 'orders'.tr,
                                          fixedWidth: 140,
                                          size: ColumnSize.L,
                                        ),
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('totalRevenue'.tr,
                                                  style: textStyle)),
                                          tooltip: 'totalRevenue'.tr,
                                          fixedWidth: 160,
                                          size: ColumnSize.L,
                                        ),
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                            child: Text('totalProfit'.tr,
                                                style: textStyle),
                                          ),
                                          tooltip: 'totalProfit'.tr,
                                          fixedWidth: 140,
                                          size: ColumnSize.L,
                                        ),
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('costPrice'.tr,
                                                  style: textStyle)),
                                          tooltip: 'costPrice'.tr,
                                          fixedWidth: 140,
                                          size: ColumnSize.L,
                                        ),
                                      ],
                                      source: _ItemsDataSource(controller,
                                          screenType.isPhone, context),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'topInventoryProducts'.tr,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 24,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: screenHeight * 0.6,
                                    child: AsyncPaginatedDataTable2(
                                      key: controller.productsTableKey,
                                      rowsPerPage: controller.rowsPerPage,
                                      showCheckboxColumn: false,
                                      isVerticalScrollBarVisible: true,
                                      initialFirstRowIndex: 0,
                                      isHorizontalScrollBarVisible: true,
                                      onSelectAll: (_) {},
                                      wrapInCard: true,
                                      minWidth: 380,
                                      headingRowColor:
                                          const WidgetStatePropertyAll(
                                              Colors.white),
                                      empty: const SizedBox.shrink(),
                                      loading: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Lottie.asset(
                                          kLoadingWalkingCoffeeAnim,
                                          height: screenHeight * 0.5,
                                        ),
                                      ),
                                      columns: [
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('productName'.tr,
                                                  style: textStyle)),
                                          tooltip: 'productName'.tr,
                                          fixedWidth: 140,
                                          size: ColumnSize.L,
                                        ),
                                        DataColumn2(
                                          label: alignHorizontalWidget(
                                              child: Text('usedQuantity'.tr,
                                                  style: textStyle)),
                                          tooltip: 'usedQuantity'.tr,
                                          fixedWidth: 160,
                                          size: ColumnSize.L,
                                        ),
                                      ],
                                      source: _ProductsDataSource(controller,
                                          screenType.isPhone, context),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        GeneralReportsCard(
                                          backgroundColor: const Color.fromRGBO(
                                              255, 245, 235, 1),
                                          iconColor: const Color.fromRGBO(
                                              250, 179, 78, 1),
                                          iconBackgroundColor:
                                              const Color.fromRGBO(
                                                  255, 237, 213, 1),
                                          amount:
                                              '${controller.totalRevenue.value.toStringAsFixed(2)} EGP',
                                          subtitle: 'totalRevenue'.tr,
                                          percentageTitle:
                                              controller.lastPeriodString.value,
                                          percentage:
                                              '${controller.revenueChangePercentage.value.toStringAsFixed(1)}%',
                                          increase: controller
                                                  .revenueChangePercentage
                                                  .value >=
                                              0,
                                          icon: Icons.monetization_on_outlined,
                                          loading:
                                              controller.loadingSales.value,
                                        ),
                                        const SizedBox(height: 16),
                                        GeneralReportsCard(
                                          backgroundColor: const Color.fromRGBO(
                                              242, 238, 255, 1),
                                          iconColor: const Color.fromRGBO(
                                              149, 111, 255, 1),
                                          iconBackgroundColor:
                                              const Color.fromRGBO(
                                                  226, 213, 255, 1),
                                          amount: controller.totalOrders.value
                                              .toString(),
                                          subtitle: 'totalOrders'.tr,
                                          percentageTitle:
                                              controller.lastPeriodString.value,
                                          percentage:
                                              '${controller.ordersChangePercentage.value.toStringAsFixed(1)}%',
                                          increase: controller
                                                  .ordersChangePercentage
                                                  .value >=
                                              0,
                                          icon: FontAwesomeIcons.listUl,
                                          loading:
                                              controller.loadingSales.value,
                                        ),
                                        const SizedBox(height: 16),
                                        GeneralReportsCard(
                                          backgroundColor: const Color.fromRGBO(
                                              229, 250, 251, 1),
                                          iconColor: const Color.fromRGBO(
                                              41, 207, 219, 1),
                                          iconBackgroundColor:
                                              const Color.fromRGBO(
                                                  211, 249, 250, 1),
                                          amount: controller
                                              .totalRegularCustomerOrders.value
                                              .toString(),
                                          subtitle: 'regularCustomerOrders'.tr,
                                          percentageTitle:
                                              controller.lastPeriodString.value,
                                          percentage:
                                              '${controller.customersChangePercentage.value.toStringAsFixed(1)}%',
                                          increase: controller
                                                  .customersChangePercentage
                                                  .value >=
                                              0,
                                          icon: Icons.people_rounded,
                                          loading:
                                              controller.loadingSales.value,
                                        ),
                                        const SizedBox(height: 16),
                                        SalesProfitCard(
                                          totalProfit:
                                              '${controller.totalProfit.value.toStringAsFixed(2)} EGP',
                                          totalCostPrice:
                                              '${controller.totalCostPrice.value.toStringAsFixed(2)} EGP',
                                          percentage:
                                              '${controller.customersChangePercentage.value.toStringAsFixed(1)}%',
                                          percentageTitle:
                                              controller.lastPeriodString.value,
                                          increase: controller
                                                  .customersChangePercentage
                                                  .value >=
                                              0,
                                          loading:
                                              controller.loadingSales.value,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'topInventoryProducts'.tr,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 24,
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: screenHeight * 0.7,
                                          child: AsyncPaginatedDataTable2(
                                            key: controller.productsTableKey,
                                            rowsPerPage: controller.rowsPerPage,
                                            showCheckboxColumn: false,
                                            isVerticalScrollBarVisible: true,
                                            initialFirstRowIndex: 0,
                                            isHorizontalScrollBarVisible: true,
                                            onSelectAll: (_) {},
                                            wrapInCard: true,
                                            minWidth: 380,
                                            headingRowColor:
                                                const WidgetStatePropertyAll(
                                                    Colors.white),
                                            empty: const SizedBox.shrink(),
                                            loading: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Lottie.asset(
                                                kLoadingWalkingCoffeeAnim,
                                                height: screenHeight * 0.5,
                                              ),
                                            ),
                                            columns: [
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text(
                                                        'productName'.tr,
                                                        style: textStyle)),
                                                tooltip: 'productName'.tr,
                                                fixedWidth: 140,
                                                size: ColumnSize.L,
                                              ),
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text(
                                                        'usedQuantity'.tr,
                                                        style: textStyle)),
                                                tooltip: 'usedQuantity'.tr,
                                                fixedWidth: 160,
                                                size: ColumnSize.L,
                                              ),
                                            ],
                                            source: _ProductsDataSource(
                                                controller,
                                                screenType.isPhone,
                                                context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        SalesAnalyticsCard(
                                          completePercent: controller
                                              .completeOrderPercentage.value,
                                          returnPercent: controller
                                              .returnedOrderPercentage.value,
                                          canceledPercent: controller
                                              .canceledOrderPercentage.value,
                                          isPhone: screenType.isPhone,
                                        ),
                                        const SizedBox(height: 16),
                                        OrdersAnalyticsCard(
                                          dineInPercent: controller
                                              .dineInOrdersPercentage.value,
                                          takeawayPercent: controller
                                              .takeawayOrdersPercentage.value,
                                          isPhone: screenType.isPhone,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'topSoldItems'.tr,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 24,
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: screenHeight * 0.7,
                                          child: AsyncPaginatedDataTable2(
                                            key: controller.itemsTableKey,
                                            rowsPerPage: controller.rowsPerPage,
                                            showCheckboxColumn: false,
                                            isVerticalScrollBarVisible: true,
                                            initialFirstRowIndex: 0,
                                            isHorizontalScrollBarVisible: true,
                                            onSelectAll: (_) {},
                                            wrapInCard: true,
                                            minWidth: 1100,
                                            headingRowColor:
                                                const WidgetStatePropertyAll(
                                                    Colors.white),
                                            empty: const SizedBox.shrink(),
                                            loading: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Lottie.asset(
                                                kLoadingWalkingCoffeeAnim,
                                                height: screenHeight * 0.5,
                                              ),
                                            ),
                                            columns: [
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text('itemName'.tr,
                                                        style: textStyle)),
                                                tooltip: 'itemName'.tr,
                                                fixedWidth: 140,
                                                size: ColumnSize.L,
                                              ),
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text('orders'.tr,
                                                        style: textStyle)),
                                                tooltip: 'orders'.tr,
                                                fixedWidth: 140,
                                                size: ColumnSize.L,
                                              ),
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text(
                                                        'totalRevenue'.tr,
                                                        style: textStyle)),
                                                tooltip: 'totalRevenue'.tr,
                                                fixedWidth: 160,
                                                size: ColumnSize.L,
                                              ),
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                  child: Text('totalProfit'.tr,
                                                      style: textStyle),
                                                ),
                                                tooltip: 'totalProfit'.tr,
                                                fixedWidth: 140,
                                                size: ColumnSize.L,
                                              ),
                                              DataColumn2(
                                                label: alignHorizontalWidget(
                                                    child: Text('costPrice'.tr,
                                                        style: textStyle)),
                                                tooltip: 'costPrice'.tr,
                                                fixedWidth: 140,
                                                size: ColumnSize.L,
                                              ),
                                            ],
                                            source: _ItemsDataSource(controller,
                                                screenType.isPhone, context),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsDataSource extends AsyncDataTableSource {
  final SalesScreenController controller;
  final bool isPhone;
  final BuildContext context;
  _ItemsDataSource(this.controller, this.isPhone, this.context);
  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
    if (startIndex + count > controller.itemsList.length) {
      await controller.fetchMostOrderedItems(start: startIndex, limit: count);
    }
    final rows = <DataRow>[];
    for (int i = startIndex; i < startIndex + count; i++) {
      if (i >= controller.itemsList.length) break;
      final item = controller.itemsList[i];
      rows.add(
        DataRow(
          cells: [
            DataCell(
                onTap: () => controller.viewItemInventoryUsage(
                    isPhone: isPhone,
                    productsUsage: item.usedProducts,
                    context: context),
                alignHorizontalWidget(
                  child: Text(
                    item.name,
                    style: textStyle,
                  ),
                )),
            DataCell(
                onTap: () => controller.viewItemInventoryUsage(
                    isPhone: isPhone,
                    productsUsage: item.usedProducts,
                    context: context),
                alignHorizontalWidget(
                  child: Text(
                    item.totalOrders.toString(),
                    style: textStyle,
                  ),
                )),
            DataCell(
                onTap: () => controller.viewItemInventoryUsage(
                    isPhone: isPhone,
                    productsUsage: item.usedProducts,
                    context: context),
                alignHorizontalWidget(
                    child: Text(
                  '${item.totalRevenue.toStringAsFixed(2)} EGP',
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.viewItemInventoryUsage(
                    isPhone: isPhone,
                    productsUsage: item.usedProducts,
                    context: context),
                alignHorizontalWidget(
                    child: Text(
                  '${item.totalProfit.toStringAsFixed(2)} EGP',
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.viewItemInventoryUsage(
                    isPhone: isPhone,
                    productsUsage: item.usedProducts,
                    context: context),
                alignHorizontalWidget(
                    child: Text(
                  '${item.totalCostPrice.toStringAsFixed(2)} EGP',
                  style: textStyle,
                ))),
          ],
          color: const WidgetStatePropertyAll(Colors.white),
        ),
      );
    }

    return AsyncRowsResponse(controller.totalItemsCount, rows);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.totalItemsCount;

  @override
  int get selectedRowCount => 0;
}

class _ProductsDataSource extends AsyncDataTableSource {
  final SalesScreenController controller;
  final bool isPhone;
  final BuildContext context;
  _ProductsDataSource(this.controller, this.isPhone, this.context);
  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
    if (startIndex + count > controller.productsList.length) {
      await controller.fetchTopUsedInventoryProducts(
          start: startIndex, limit: count);
    }
    final rows = <DataRow>[];
    for (int i = startIndex; i < startIndex + count; i++) {
      if (i >= controller.productsList.length) break;
      final product = controller.productsList[i];
      rows.add(
        DataRow(
          cells: [
            DataCell(alignHorizontalWidget(
              child: Text(
                product.productName,
                style: textStyle,
              ),
            )),
            DataCell(alignHorizontalWidget(
              child: Text(
                '${product.totalQuantity} ${product.measuringUnit.tr}',
                style: textStyle,
              ),
            )),
          ],
          color: const WidgetStatePropertyAll(Colors.white),
        ),
      );
    }

    return AsyncRowsResponse(controller.totalItemsCount, rows);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.totalItemsCount;

  @override
  int get selectedRowCount => 0;
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;

  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
