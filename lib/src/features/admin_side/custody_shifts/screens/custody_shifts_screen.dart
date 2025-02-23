import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../controllers/custody_screen_controller.dart';

class CustodyShiftsScreen extends StatelessWidget {
  const CustodyShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(CustodyReportsController());
    final statusSelectOptions = [
      'allShifts'.tr,
      'activeShifts'.tr,
      'closedShifts'.tr,
    ];
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 16);
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'custodyShifts'.tr,
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
                  width: 160,
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'selectStatus'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        items: statusSelectOptions
                            .map(
                              (String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: statusSelectOptions
                            .elementAt(controller.currentSelectedStatus.value),
                        onChanged: (value) => value != null
                            ? controller.onShiftStatusChanged(
                                value, statusSelectOptions.indexOf(value))
                            : controller.onShiftStatusChanged(
                                'allShifts'.tr, 0),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        buttonStyleData: ButtonStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 40,
                          width: 160,
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => SizedBox(
                    width: controller.dateRangeOptions.keys.length > 6
                        ? controller.dateRangeOptions.keys
                                .toList()
                                .elementAt(controller.currentSelectedDate.value)
                                .contains('-')
                            ? screenType.isPhone
                                ? 210
                                : 280
                            : 170
                        : 150,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          'selectDate'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                                          controller
                                                  .currentSelectedDate.value ==
                                              6
                                      ? const BoxConstraints(maxWidth: 220)
                                      : null,
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    item,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
                          width: 140,
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
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
                    completeIcon: const Icon(Icons.done, color: Colors.grey),
                    idleIcon:
                        const Icon(Icons.arrow_downward, color: Colors.grey),
                    releaseIcon: const Icon(Icons.refresh, color: Colors.grey),
                  ),
                  controller: controller.shiftsRefreshController,
                  onRefresh: () => controller.onShiftsRefresh(),
                  child: Obx(
                    () => AsyncPaginatedDataTable2(
                      key: controller.tableKey,
                      rowsPerPage: controller.rowsPerPage,
                      showCheckboxColumn: false,
                      isVerticalScrollBarVisible: true,
                      initialFirstRowIndex: 0,
                      isHorizontalScrollBarVisible: true,
                      sortColumnIndex: controller.sortColumnIndex.value,
                      sortAscending: controller.sortAscending.value,
                      onSelectAll: (_) {},
                      wrapInCard: true,
                      minWidth: 2500,
                      headingRowColor:
                          const WidgetStatePropertyAll(Colors.white),
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
                              child: Text('openingTime'.tr, style: textStyle)),
                          tooltip: 'openingTime'.tr,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child: Text('closingTime'.tr, style: textStyle)),
                          tooltip: 'closingTime'.tr,
                          fixedWidth: 230,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child:
                                  Text('openingAmount'.tr, style: textStyle)),
                          tooltip: 'openingAmount'.tr,
                          numeric: true,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                            child: Text('cashPaymentsNet'.tr, style: textStyle),
                          ),
                          tooltip: 'cashPaymentsNet'.tr,
                          numeric: true,
                          fixedWidth: 240,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child: Text('totalPayIns'.tr, style: textStyle)),
                          tooltip: 'totalPayIns'.tr,
                          numeric: true,
                          fixedWidth: 180,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child: Text('totalPayOuts'.tr, style: textStyle)),
                          tooltip: 'totalPayOuts'.tr,
                          numeric: true,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child: Text('cashDrop'.tr, style: textStyle)),
                          tooltip: 'cashDrop'.tr,
                          fixedWidth: 160,
                          size: ColumnSize.L,
                          numeric: true,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child:
                                  Text('closingAmount'.tr, style: textStyle)),
                          tooltip: 'closingAmount'.tr,
                          numeric: true,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                            child: Text('expectedDrawerMoney'.tr,
                                style: textStyle),
                          ),
                          tooltip: 'expectedDrawerMoney'.tr,
                          numeric: true,
                          fixedWidth: 260,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                              child: Text('difference'.tr, style: textStyle)),
                          tooltip: 'difference'.tr,
                          numeric: true,
                          fixedWidth: 160,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                            child: Text('drawerOpenCount'.tr, style: textStyle),
                          ),
                          tooltip: 'drawerOpenCount'.tr,
                          numeric: true,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                          onSort: (index, ascending) =>
                              controller.sortData(index, ascending),
                        ),
                      ],
                      source:
                          _CustodyDataSource(controller, screenType.isPhone),
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

class _CustodyDataSource extends AsyncDataTableSource {
  final CustodyReportsController controller;
  final bool isPhone;
  _CustodyDataSource(this.controller, this.isPhone);
  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
    if (startIndex + count > controller.reports.length) {
      await controller.fetchData(start: startIndex, limit: count);
    }

    final rows = <DataRow>[];
    for (int i = startIndex; i < startIndex + count; i++) {
      if (i >= controller.reports.length) break;

      final custody = controller.reports[i];

      rows.add(
        DataRow(
          cells: [
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                  child: Text(
                    DateFormat('MMM dd, yyyy, hh:mm a',
                            isLangEnglish() ? 'en_US' : 'ar_SA')
                        .format(custody.openingTime.toDate()),
                    style: textStyle,
                  ),
                )),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                  child: Text(
                    custody.isActive
                        ? 'active'.tr
                        : DateFormat('MMM dd, yyyy, hh:mm a',
                                isLangEnglish() ? 'en_US' : 'ar_SA')
                            .format(custody.closingTime.toDate()),
                    style: textStyle,
                  ),
                )),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.openingAmount.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.cashPaymentsNet.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.totalPayIns.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.totalPayOuts.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.cashDrop.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.closingAmount.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.expectedDrawerMoney.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.difference.toString(),
                  style: textStyle,
                ))),
            DataCell(
                onTap: () => controller.onReportTap(
                    isPhone: isPhone, custodyReport: custody),
                alignHorizontalWidget(
                    child: Text(
                  custody.drawerOpenCount.toString(),
                  style: textStyle,
                ))),
          ],
          color: const WidgetStatePropertyAll(Colors.white),
        ),
      );
    }

    return AsyncRowsResponse(controller.totalShiftsCount, rows);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.totalShiftsCount;

  @override
  int get selectedRowCount => 0;
}
