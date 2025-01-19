import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/general_functions.dart';
import '../controllers/custody_transactions_controller.dart';

class CustodyShiftTransactionsScreen extends StatelessWidget {
  const CustodyShiftTransactionsScreen(
      {super.key, required this.custodyReportId});
  final String custodyReportId;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(
        CustodyTransactionsController(custodyReportId: custodyReportId));
    return Scaffold(
      appBar: AppBar(
        leading: const RegularBackButton(padding: 0),
        elevation: 0,
        centerTitle: true,
        title: AutoSizeText(
          'custodyTransactions'.tr,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: Lottie.asset(
                    kLoadingWalkingCoffeeAnim,
                    height: screenHeight * 0.5,
                  ),
                )
              : RefreshConfiguration(
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
                      releaseIcon:
                          const Icon(Icons.refresh, color: Colors.grey),
                    ),
                    controller: controller.transactionsRefreshController,
                    onRefresh: () => controller.onTransactionsRefresh(),
                    child: AsyncPaginatedDataTable2(
                      rowsPerPage: controller.rowsPerPage,
                      onPageChanged: (startRowIndex) {
                        controller.fetchData(start: startRowIndex);
                      },
                      showCheckboxColumn: false,
                      isVerticalScrollBarVisible: true,
                      isHorizontalScrollBarVisible: true,
                      sortColumnIndex: controller.sortColumnIndex.value,
                      sortAscending: controller.sortAscending.value,
                      onSelectAll: (_) {},
                      wrapInCard: true,
                      minWidth: 1460,
                      headingRowColor:
                          const WidgetStatePropertyAll(Colors.white),
                      empty: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              kEmptyCoffeeCupAnim,
                              fit: BoxFit.contain,
                              height: screenHeight * 0.3,
                            ),
                            AutoSizeText(
                              'noCustodyTransactionsFoundTitle'.tr,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5.0),
                          ],
                        ),
                      ),
                      columns: [
                        DataColumn2(
                          label: alignHorizontalWidget(
                            child: Text(
                              'time'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          tooltip: 'time'.tr,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: alignHorizontalWidget(
                            child: Text(
                              'transactionType'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          tooltip: 'transactionType'.tr,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Align(
                            alignment: isLangEnglish()
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Text(
                              'amount'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          tooltip: 'amount'.tr,
                          numeric: true,
                          fixedWidth: 200,
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Align(
                            alignment: isLangEnglish()
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Text(
                              'description'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          tooltip: 'description'.tr,
                          numeric: true,
                          fixedWidth: 800,
                          size: ColumnSize.L,
                        ),
                      ],
                      source: _CustodyDataSource(controller),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CustodyDataSource extends AsyncDataTableSource {
  final CustodyTransactionsController controller;

  _CustodyDataSource(this.controller);
  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    if (startIndex >= controller.data.length) {
      return AsyncRowsResponse(0, []);
    }

    final rows = <DataRow>[];

    for (int i = startIndex; i < startIndex + count; i++) {
      if (i >= controller.data.length) break;

      final transaction = controller.data[i];

      rows.add(
        DataRow(
          cells: [
            DataCell(alignHorizontalWidget(
              child: Text(
                DateFormat('MMM dd, yyyy, hh:mm a',
                        isLangEnglish() ? 'en_US' : 'ar_SA')
                    .format(transaction.timestamp.toDate()),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            )),
            DataCell(alignHorizontalWidget(
              child: Text(
                transaction.type.name.tr,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            )),
            DataCell(alignHorizontalWidget(
              child: Text(
                transaction.amount.toStringAsFixed(2),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            )),
            DataCell(alignHorizontalWidget(
              child: Text(
                transaction.description.isNotEmpty
                    ? transaction.description
                    : 'noDescription'.tr,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            )),
          ],
          color: const WidgetStatePropertyAll(Colors.white),
        ),
      );
    }

    return AsyncRowsResponse(controller.totalItems.value, rows);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.data.length;

  @override
  int get selectedRowCount => 0;
}
