import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/main_screen/components/models.dart';
import '../components/custody_select.dart';
import '../components/custody_select_phone.dart';
import '../components/custody_transactions_screen.dart';

class CustodyReportsController extends GetxController {
  static CustodyReportsController get instance => Get.find();
  final int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = false.obs;
  final RxList<CustodyReport> reports = <CustodyReport>[].obs;
  int totalTransactionsCount = 0;
  final RxInt currentSelectedStatus = 0.obs;
  late final GlobalKey<AsyncPaginatedDataTable2State> tableKey;
  int selectedSortColumnIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _searchDebounce;
  String searchText = '';
  final RxMap<String, Map<String, DateTime>> dateRangeOptions =
      <String, Map<String, DateTime>>{}.obs;
  late DateTime? dateFrom;
  late DateTime? dateTo;
  final RxInt currentSelectedDate = 0.obs;
  final RefreshController shiftsRefreshController =
      RefreshController(initialRefresh: false);
  DocumentSnapshot? lastDocument;
  @override
  void onInit() {
    super.onInit();
    tableKey = GlobalKey<AsyncPaginatedDataTable2State>();
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _initializeDateRangeOptions();
  }

  void updateDateFilters() {
    _initializeDateRangeOptions();
  }

  void updateNewDayDateFilters() {
    _initializeDateRangeOptions();
    resetTableValues();
    //fetchData(start: currentStartIndex);
  }

  void resetTableValues() {
    reports.clear();
    lastDocument = null;
    totalTransactionsCount = 0;
    tableKey.currentState!.pageTo(0);
  }

  void _initializeDateRangeOptions() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final daysSinceSaturday = (now.weekday % 7);
    final startOfThisWeek =
        todayStart.subtract(Duration(days: daysSinceSaturday));
    String customDateElementKey = '';
    Map<String, DateTime> customDateElementValue = {};
    if (dateRangeOptions.length > 6) {
      customDateElementKey = dateRangeOptions.keys.elementAt(6);
      customDateElementValue = dateRangeOptions[customDateElementKey]!;
      String dateFormatted =
          DateFormat('MMM dd, yyyy', isLangEnglish() ? 'en_US' : 'ar_SA')
              .format(dateFrom!);
      if (dateFrom!.day != dateTo!.day) {
        dateFormatted +=
            ' - ${DateFormat('MMM dd, yyyy', isLangEnglish() ? 'en_US' : 'ar_SA').format(dateTo!)}';
      }
      customDateElementKey = dateFormatted;
    }
    dateRangeOptions.assignAll({
      'today'.tr: {
        "from": todayStart,
        "to": todayEnd,
      },
      'yesterday'.tr: {
        "from": todayStart.subtract(const Duration(days: 1)),
        "to": todayStart.subtract(const Duration(seconds: 1)),
      },
      'thisWeek'.tr: {
        "from": startOfThisWeek,
        "to": todayEnd,
      },
      'thisMonth'.tr: {
        "from": DateTime(now.year, now.month, 1),
        "to": todayEnd,
      },
      'thisYear'.tr: {
        "from": DateTime(now.year, 1, 1),
        "to": todayEnd,
      },
      'customDate'.tr: {
        "from": todayStart,
        "to": todayEnd,
      },
    });
    if (customDateElementKey.trim().isNotEmpty) {
      dateRangeOptions[customDateElementKey] = customDateElementValue;
    }
  }

  void applyPredefinedDateRange(
      String key, BuildContext context, int index) async {
    if (currentSelectedDate.value != index) {
      try {
        if (key == 'customDate'.tr) {
          final results = await showCalendarDatePicker2Dialog(
            dialogBackgroundColor: Colors.white,
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
              selectedDayHighlightColor: Colors.black,
              selectedRangeHighlightColor: Colors.grey.shade200,
              daySplashColor: Colors.grey.shade200,
              calendarType: CalendarDatePicker2Type.range,
            ),
            dialogSize: const Size(475, 375),
            borderRadius: BorderRadius.circular(15),
          );
          if (results != null) {
            if (results.first != null) {
              dateFrom = results.first!;
              dateTo = results.last!;
              String dateFormatted = DateFormat(
                      'MMM dd, yyyy', isLangEnglish() ? 'en_US' : 'ar_SA')
                  .format(dateFrom!);
              dateTo = DateTime(results.last!.year, results.last!.month,
                  results.last!.day, 23, 59, 59);
              if (dateFrom!.day != dateTo!.day) {
                dateFormatted +=
                    ' - ${DateFormat('MMM dd, yyyy', isLangEnglish() ? 'en_US' : 'ar_SA').format(dateTo!)}';
              }
              final dateKey = dateRangeOptions.keys
                  .toList()
                  .elementAt(currentSelectedDate.value);
              if (isDate(dateKey)) {
                dateRangeOptions.remove(dateKey);
              }
              dateRangeOptions[dateFormatted] = {
                "from": dateFrom!,
                "to": dateTo!,
              };
              currentSelectedDate.value = dateRangeOptions.length - 1;
              resetTableValues();
              // fetchData(start: currentStartIndex);
            }
          } else {
            resetDateFilter();
          }
        } else {
          final selectedRange = dateRangeOptions[key];
          if (selectedRange != null) {
            dateFrom = selectedRange["from"];
            dateTo = selectedRange["to"];
            resetTableValues();
            // fetchData(start: currentStartIndex);
            final dateKey = dateRangeOptions.keys
                .toList()
                .elementAt(currentSelectedDate.value);
            if (isDate(dateKey)) {
              dateRangeOptions.remove(dateKey);
            }
            currentSelectedDate.value = index;
          }
        }
      } catch (error) {
        AppInit.logger.e(error.toString());
        resetDateFilter();
      }
    }
  }

  void resetDateFilter() {
    final dateKey =
        dateRangeOptions.keys.toList().elementAt(currentSelectedDate.value);
    if (isDate(dateKey) && dateRangeOptions.containsKey(dateKey)) {
      dateRangeOptions.remove(dateKey);
    }
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    currentSelectedDate.value = 0;
    resetTableValues();
    //  fetchData(start: currentStartIndex);
  }

  bool isDate(String input) {
    final yearRegex = RegExp(r'\b(?:\d{4}|[٠-٩]{4})\b');
    final normalizedInput = input.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 0x0660).toString(),
    );
    return yearRegex.hasMatch(normalizedInput);
  }

  void onCustodyShiftsSearch(String value) {
    if (value.trim().isEmpty) {
      if (searchText.isNotEmpty) {
        searchText = '';
        if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
        resetTableValues();
        //    fetchData(start: currentStartIndex);
      }
    } else {
      searchText = value;
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        resetTableValues();
        //  fetchData(start: currentStartIndex);
      });
    }
  }

  Future<void> fetchData({
    int start = 0,
    int limit = 10,
    bool ascending = false,
  }) async {
    try {
      bool? isActiveQuery;
      if (currentSelectedStatus.value == 1) {
        isActiveQuery = true;
      } else if (currentSelectedStatus.value == 2) {
        isActiveQuery = false;
      }
      final sortString = getColumnSortString(selectedSortColumnIndex);
      if (kDebugMode) {
        AppInit.logger.i('Sort object $sortString');
      }
      Query query = _firestore
          .collection('custody_shifts')
          .orderBy(sortString, descending: !ascending);

      if (isActiveQuery != null) {
        query = query.where('isActive', isEqualTo: isActiveQuery);
      }
      if (dateFrom != null) {
        query = query.where('opening_time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom!));
      }

      if (dateTo != null) {
        query = query.where('opening_time',
            isLessThanOrEqualTo: Timestamp.fromDate(dateTo!));
      }
      if (start == 0) {
        final countSnapshot = await query.count().get();
        totalTransactionsCount = countSnapshot.count ?? 0;
        lastDocument = null;
      }
      if (start != 0 && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      final querySnapshot = await query.limit(limit).get();
      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
        if (start == 0) {
          reports.assignAll(querySnapshot.docs
              .map((doc) => CustodyReport.fromFirestore(doc))
              .toList());
        } else {
          reports.addAll(querySnapshot.docs
              .map((doc) => CustodyReport.fromFirestore(doc))
              .toList());
        }
      } else if (start == 0) {
        reports.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  void sortData(int columnIndex, bool ascending) {
    selectedSortColumnIndex = columnIndex;
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;
    resetTableValues();
    //fetchData(start: currentStartIndex, ascending: ascending);
  }

  void onShiftStatusChanged(String value, index) {
    if (index != currentSelectedStatus.value) {
      currentSelectedStatus.value = index;
      resetTableValues();
      // fetchData(start: currentStartIndex);
    }
  }

  String getColumnSortString(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return 'opening_time';
      case 1:
        return 'closingTime';
      case 2:
        return 'opening_amount';
      case 3:
        return 'cash_payments_net';
      case 4:
        return 'total_pay_ins';
      case 5:
        return 'total_pay_outs';
      case 6:
        return 'cash_drop';
      case 7:
        return 'closing_amount';
      case 8:
        return 'expected_drawer_money';
      case 9:
        return 'difference';
      case 10:
        return 'drawer_open_count';
      default:
        return 'openingTime';
    }
  }

  void onShiftsRefresh() {
    resetTableValues();
    //fetchData(start: currentStartIndex);
    shiftsRefreshController.refreshCompleted();
  }

  void onReportTap(
      {required bool isPhone, required CustodyReport custodyReport}) {
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        CustodySelectPhone(
          headerText: 'chooseReportOption'.tr,
          onViewTransactionsPress: () {
            Get.back();
            Get.to(() => CustodyShiftTransactionsScreen(
                custodyReportId: custodyReport.id));
          },
          onPrintReceiptPress: () {
            Get.back();
            printCustodyReceipt(custody: custodyReport);
          },
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return CustodySelect(
            headerText: 'chooseReportOption'.tr,
            onViewTransactionsPress: () {
              Get.back();
              Get.to(() => CustodyShiftTransactionsScreen(
                  custodyReportId: custodyReport.id));
            },
            onPrintReceiptPress: () {
              Get.back();
              printCustodyReceipt(custody: custodyReport);
            },
          );
        },
      );
    }
  }
}
