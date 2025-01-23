import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';

class SalesScreenController extends GetxController {
  static SalesScreenController get instance => Get.find();
  final RxMap<String, Map<String, DateTime>> dateRangeOptions =
      <String, Map<String, DateTime>>{}.obs;
  late DateTime? dateFrom;
  late DateTime? dateTo;
  final RxInt currentSelectedDate = 0.obs;
  final RefreshController salesRefreshController =
      RefreshController(initialRefresh: false);
  late final FirebaseFirestore _firestore;
  final RxString lastPeriodString = 'fromLastDay'.tr.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt totalRegularCustomerOrders = 0.obs;
  final RxDouble revenueChangePercentage = 0.0.obs;
  final RxDouble ordersChangePercentage = 0.0.obs;
  final RxDouble customersChangePercentage = 0.0.obs;
  final totalProfit = 0.0.obs;
  final totalCostPrice = 0.0.obs;
  final profitChangePercentage = 0.0.obs;
  final completeOrderPercentage = 0.0.obs;
  final returnedOrderPercentage = 0.0.obs;
  final canceledOrderPercentage = 0.0.obs;
  final dineInOrdersPercentage = 0.0.obs;
  final takeawayOrdersPercentage = 0.0.obs;

  final RxBool loadingGeneralSales = true.obs;
  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _initializeDateRangeOptions();
    fetchGeneralSales();
  }

  void updateLanguagesFilters() {
    _initializeDateRangeOptions();

    lastPeriodString.value = getFromLastPeriodString(dateFrom!, dateTo!);
  }

  void updateNewDayDateFilters() {
    _initializeDateRangeOptions();
    fetchGeneralSales();
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
              fetchGeneralSales();
            }
          } else {
            resetDateFilter();
          }
        } else {
          final selectedRange = dateRangeOptions[key];
          if (selectedRange != null) {
            dateFrom = selectedRange["from"];
            dateTo = selectedRange["to"];
            fetchGeneralSales();
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
    fetchGeneralSales();
  }

  bool isDate(String input) {
    final yearRegex = RegExp(r'\b(?:\d{4}|[٠-٩]{4})\b');
    final normalizedInput = input.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 0x0660).toString(),
    );
    return yearRegex.hasMatch(normalizedInput);
  }

  void onRefresh() async {
    fetchGeneralSales();
    salesRefreshController.refreshCompleted();
  }

  void fetchGeneralSales() async {
    try {
      loadingGeneralSales.value = true;
      final revenueQuery = await _fetchMetricsForDateRange(dateFrom, dateTo);
      final revenue = revenueQuery['revenue'];
      final orders = revenueQuery['orders'];
      final customers = revenueQuery['customers'];
      final costPrice = revenueQuery['costPrice'];
      final statusCounts = revenueQuery['statusCounts'];
      final dineInCount = revenueQuery['dineInCount'];
      final takeawayCount = revenueQuery['takeawayCount'];
      final profit = revenue - costPrice;

      // Calculate percentages for each status
      final completePercentage =
          orders > 0 ? (statusCounts['complete'] / orders) * 100 : 0.0;
      final returnedPercentage =
          orders > 0 ? (statusCounts['returned'] / orders) * 100 : 0.0;
      final canceledPercentage =
          orders > 0 ? (statusCounts['canceled'] / orders) * 100 : 0.0;

      final dineInPercentage = orders > 0 ? (dineInCount / orders) * 100 : 0.0;
      final takeawayPercentage =
          orders > 0 ? (takeawayCount / orders) * 100 : 0.0;

      totalCostPrice.value = roundToNearestHalfOrWhole(costPrice);
      totalRevenue.value = roundToNearestHalfOrWhole(revenue);
      totalOrders.value = orders;
      totalRegularCustomerOrders.value = customers;
      totalProfit.value = roundToNearestHalfOrWhole(profit);
      completeOrderPercentage.value =
          roundToNearestHalfOrWhole(completePercentage);
      returnedOrderPercentage.value =
          roundToNearestHalfOrWhole(returnedPercentage);
      canceledOrderPercentage.value =
          roundToNearestHalfOrWhole(canceledPercentage);
      dineInOrdersPercentage.value =
          roundToNearestHalfOrWhole(dineInPercentage);
      takeawayOrdersPercentage.value =
          roundToNearestHalfOrWhole(takeawayPercentage);
      final previousRange = _getPreviousDateRange(dateFrom!, dateTo!);
      final previousQuery = await _fetchMetricsForDateRange(
          previousRange['from'], previousRange['to']);
      final previousRevenue = previousQuery['revenue'];
      final previousOrders = previousQuery['orders'];
      final previousCustomers = previousQuery['customers'];
      final previousCostPrice = previousQuery['costPrice'];
      final previousProfit = previousRevenue - previousCostPrice;

      revenueChangePercentage.value =
          _calculatePercentageChange(previousRevenue, revenue);
      ordersChangePercentage.value = _calculatePercentageChange(
          previousOrders.toDouble(), orders.toDouble());
      customersChangePercentage.value = _calculatePercentageChange(
          previousCustomers.toDouble(), customers.toDouble());
      profitChangePercentage.value =
          _calculatePercentageChange(previousProfit, profit);

      lastPeriodString.value = getFromLastPeriodString(dateFrom!, dateTo!);
    } catch (e) {
      if (kDebugMode) AppInit.logger.e('Error fetching metrics: $e');
    } finally {
      loadingGeneralSales.value = false;
    }
  }

  Future<Map<String, dynamic>> _fetchMetricsForDateRange(
      DateTime? from, DateTime? to) async {
    try {
      final query = await _firestore
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: from)
          .where('timestamp', isLessThanOrEqualTo: to)
          .where('status', isNotEqualTo: 'active')
          .get();

      double revenue = 0.0;
      double totalCostPrice = 0.0;
      int orders = query.docs.length;
      int customers = 0;
      int dineInCount = 0;
      int takeawayCount = 0;
      final statusCounts = {
        'complete': 0,
        'returned': 0,
        'canceled': 0,
      };

      for (var doc in query.docs) {
        final data = doc.data();
        revenue += data['totalAmount'] ?? 0.0;

        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          totalCostPrice += item['costPrice'] ?? 0.0;
        }

        final status = data['status'] ?? '';
        if (statusCounts.containsKey(status)) {
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        final isTakeaway = data['isTakeaway'] ?? false;
        if (isTakeaway) {
          takeawayCount++;
        } else {
          dineInCount++;
        }
        if (data['customerId'] != null) {
          customers++;
        }
      }

      return {
        'revenue': revenue,
        'costPrice': totalCostPrice,
        'orders': orders,
        'customers': customers,
        'statusCounts': statusCounts,
        'dineInCount': dineInCount,
        'takeawayCount': takeawayCount,
      };
    } catch (e) {
      if (kDebugMode) AppInit.logger.e('Error fetching metrics for range: $e');
      return {
        'revenue': 0.0,
        'costPrice': 0.0,
        'orders': 0,
        'customers': 0,
        'statusCounts': {
          'complete': 0,
          'returned': 0,
          'canceled': 0,
        },
        'dineInCount': 0,
        'takeawayCount': 0,
      };
    }
  }

  Map<String, DateTime> _getPreviousDateRange(DateTime from, DateTime to) {
    final duration = to.difference(from);
    return {
      'from': from.subtract(duration),
      'to': to.subtract(duration),
    };
  }

  double _calculatePercentageChange(double previous, double current) {
    if (previous == 0) return 100.0;
    return ((current - previous) / previous) * 100;
  }

  String getFromLastPeriodString(DateTime dateFrom, DateTime dateTo) {
    final difference = dateTo.difference(dateFrom).inDays + 1;

    if (difference == 1) {
      return 'fromLastDay'.tr;
    } else if (difference <= 31) {
      return 'fromPreviousDays'.trParams({'difference': difference.toString()});
    } else if (difference <= 366) {
      final months = (difference / 30).round();
      return months > 1
          ? 'fromPreviousMonths'.trParams({'difference': months.toString()})
          : 'fromPreviousMonth'.trParams({'difference': months.toString()});
    } else {
      final years = (difference / 365).round();
      return years > 1
          ? 'fromPreviousYears'.trParams({'difference': years.toString()})
          : 'fromPreviousYear'.trParams({'difference': years.toString()});
    }
  }

  @override
  void onClose() {
    salesRefreshController.dispose();
    super.onClose();
  }
}
