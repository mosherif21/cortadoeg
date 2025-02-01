import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/orders/components/models.dart';

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
  final totalTaxAmount = 0.0.obs;
  final totalDiscountAmount = 0.0.obs;
  final profitChangePercentage = 0.0.obs;
  final completeOrderPercentage = 0.0.obs;
  final returnedOrderPercentage = 0.0.obs;
  final canceledOrderPercentage = 0.0.obs;
  final dineInOrdersPercentage = 0.0.obs;
  final takeawayOrdersPercentage = 0.0.obs;
  final RxBool loadingSales = true.obs;
  final int rowsPerPage = 8;
  int totalItemsCount = 0;
  int totalProductsCount = 0;
  int totalEmployeesCount = 0;

  double takeawayPercentage = 10;
  List<OrderModel> ordersList = [];
  List<ItemReport> itemsList = [];
  List<InventoryReport> productsList = [];
  final updateItemsTable = 0.obs;
  final updateEmployeesTable = 0.obs;
  final updateProductsTable = 0.obs;
  List<TakeawayEmployeeReport> employeesList = [];
  late final StreamSubscription takeawayPercentListener;
  StreamSubscription? ordersListener;
  final Rxn<String?> selectedShiftId = Rxn<String>(null);
  List<AvailableShift> availableShifts = <AvailableShift>[];
  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _initializeDateRangeOptions();
    _listenToGeneralSalesOrders();
  }

  @override
  void onReady() {
    takeawayPercentListener = listenToTakeawayPercent().listen((percent) {
      if (percent != null) {
        takeawayPercentage = percent;
        _listenToGeneralSalesOrders();
      }
    });
    super.onReady();
  }

  void _listenToGeneralSalesOrders() {
    try {
      loadingSales.value = true;
      ordersList.clear();
      ordersListener?.cancel();
      resetItemsTableValues();
      resetProductsTableValues();
      resetEmployeesTableValues();
      final CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('orders');
      Query query = ordersRef;

      if (dateFrom != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: dateFrom);
      }

      if (dateTo != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: dateTo);
      }
      query = query.where('status', isNotEqualTo: 'active');
      ordersListener = query.snapshots().listen((snapshot) async {
        double revenue = 0.0;
        double costPrice = 0.0;
        double taxAmount = 0.0;
        double discountAmount = 0.0;
        int ordersCount = snapshot.docs.length;
        int customers = 0;
        int dineInCount = 0;
        int takeawayCount = 0;
        final statusCounts = {
          'complete': 0,
          'returned': 0,
          'canceled': 0,
        };

        ordersList = snapshot.docs.map((doc) {
          final data = doc.data();
          final order =
              OrderModel.fromFirestore(data as Map<String, dynamic>, doc.id);

          if (statusCounts.containsKey(order.status.name)) {
            statusCounts[order.status.name] =
                (statusCounts[order.status.name] ?? 0) + 1;
          }

          if (order.isTakeaway) {
            takeawayCount++;
          } else {
            dineInCount++;
          }
          if (order.customerId != null) {
            customers++;
          }
          if (order.status.name == 'complete') {
            revenue += order.totalAmount;
            taxAmount += order.taxTotalAmount;
            discountAmount += order.discountAmount;
            for (var item in order.items) {
              costPrice += (item.costPrice) * item.quantity;
            }
          } else if (order.status.name == 'returned') {
            for (var item in order.items) {
              costPrice += (item.costPrice) * item.quantity;
            }
          }
          return order;
        }).toList();
        onOrdersListUpdate();
        fetchMostOrderedItems();
        fetchTakeawayEmployeesData();
        fetchTopUsedInventoryProducts();

        final double profit = revenue - costPrice - taxAmount - discountAmount;
        final double completePercentage = ordersCount > 0
            ? ((statusCounts['complete'] ?? 0) / ordersCount) * 100
            : 0.0;
        final double returnedPercentage = ordersCount > 0
            ? ((statusCounts['returned'] ?? 0) / ordersCount) * 100
            : 0.0;
        final double canceledPercentage = ordersCount > 0
            ? ((statusCounts['canceled'] ?? 0) / ordersCount) * 100
            : 0.0;

        final double dineInPercentage =
            ordersCount > 0 ? (dineInCount / ordersCount) * 100 : 0.0;
        final double takeawayPercentage =
            ordersCount > 0 ? (takeawayCount / ordersCount) * 100 : 0.0;

        totalCostPrice.value = roundToNearestHalfOrWhole(costPrice);
        totalRevenue.value = roundToNearestHalfOrWhole(revenue);
        totalOrders.value = ordersCount;
        totalRegularCustomerOrders.value = customers;
        totalTaxAmount.value = roundToNearestHalfOrWhole(taxAmount);
        totalDiscountAmount.value = roundToNearestHalfOrWhole(discountAmount);
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
            previousOrders.toDouble(), ordersCount.toDouble());
        customersChangePercentage.value = _calculatePercentageChange(
            previousCustomers.toDouble(), customers.toDouble());
        profitChangePercentage.value =
            _calculatePercentageChange(previousProfit, profit);

        lastPeriodString.value = getFromLastPeriodString(dateFrom!, dateTo!);

        loadingSales.value = false;
      }, onError: (error) {
        if (kDebugMode) {
          AppInit.logger.e(error.toString());
        }
      });
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
  }

  Stream<double?> listenToTakeawayPercent() {
    final takeawayPercentRef = FirebaseFirestore.instance
        .collection('employees')
        .doc('employeeVariables');
    return takeawayPercentRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final takeawayPercentage =
            snapshot.data()!['takeawayPercentage'] as double;
        return takeawayPercentage;
      }
      return null;
    });
  }

  void resetEmployeesTableValues() {
    employeesList.clear();
    totalEmployeesCount = 0;
  }

  void resetItemsTableValues() {
    itemsList.clear();
    totalItemsCount = 0;
  }

  void resetProductsTableValues() {
    productsList.clear();
    totalProductsCount = 0;
  }

  void viewItemInventoryUsage(
      {required bool isPhone,
      required Map<String, ProductUsage> productsUsage,
      required BuildContext context}) {
    if (isPhone) {
      showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        duration: const Duration(milliseconds: 500),
        minHeight: 0,
        initHeight: 0.75,
        maxHeight: 1,
        anchors: [0, 0.75, 1],
        isSafeArea: true,
        context: context,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            width: double.maxFinite,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                  ),
                  height: 7,
                  width: 40,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AutoSizeText(
                          'inventoryUsage'.tr,
                          maxLines: 2,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StretchingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: productsUsage.entries.map((entry) {
                                  final productName = entry.value.productName;
                                  final quantity = entry.value.quantity;
                                  final measuringUnit =
                                      entry.value.measuringUnit;
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      '$productName: $quantity ${measuringUnit.tr}',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                }).toList(),
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
          );
        },
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                height: 700,
                width: 450,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              'inventoryUsage'.tr,
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: StretchingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        productsUsage.entries.map((entry) {
                                      final productName =
                                          entry.value.productName;
                                      final quantity = entry.value.quantity;
                                      final measuringUnit =
                                          entry.value.measuringUnit;
                                      return Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          '$productName: $quantity ${measuringUnit.tr}',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: isLangEnglish() ? 5 : null,
                      left: isLangEnglish() ? null : 5,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void updateLanguagesFilters() {
    _initializeDateRangeOptions();

    lastPeriodString.value = getFromLastPeriodString(dateFrom!, dateTo!);
  }

  void updateNewDayDateFilters() {
    _initializeDateRangeOptions();
    _listenToGeneralSalesOrders();
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
              _listenToGeneralSalesOrders();
            }
          } else {
            resetDateFilter();
          }
        } else {
          final selectedRange = dateRangeOptions[key];
          if (selectedRange != null) {
            dateFrom = selectedRange["from"];
            dateTo = selectedRange["to"];
            _listenToGeneralSalesOrders();
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
    _listenToGeneralSalesOrders();
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
    _listenToGeneralSalesOrders();
    salesRefreshController.refreshCompleted();
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
      double taxAmount = 0.0;
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

        final status = data['status'] ?? '';

        if (status != 'canceled') {
          revenue += data['totalAmount'] ?? 0.0;

          final items = data['items'] as List<dynamic>? ?? [];
          for (var item in items) {
            totalCostPrice += item['costPrice'] ?? 0.0;
          }

          taxAmount += data['taxTotalAmount'] ?? 0.0;
        }

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
        'taxAmount': taxAmount,
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
        'taxAmount': 0.0,
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

  void onOrdersListUpdate() {
    generateAvailableShifts();
    if (availableShifts.isNotEmpty) {
      selectedShiftId.value = availableShifts.first.shiftId;
    } else {
      selectedShiftId.value = null;
    }
    fetchTakeawayEmployeesData();
  }

  void generateAvailableShifts() {
    final Map<String, DateTime> shiftMap = {};
    for (var order in ordersList) {
      if (!shiftMap.containsKey(order.shiftId)) {
        shiftMap[order.shiftId] = order.shiftOpeningTime.toDate();
      }
    }
    availableShifts = shiftMap.entries.map((entry) {
      return AvailableShift(
        shiftId: entry.key,
        openingTime: entry.value,
      );
    }).toList();
    availableShifts.sort((a, b) => b.openingTime.compareTo(a.openingTime));
  }

  void fetchTakeawayEmployeesData() {
    try {
      Map<String, dynamic> employeeMetrics = {};

      for (var order in ordersList) {
        if (selectedShiftId.value != null &&
            order.shiftId != selectedShiftId.value) {
          continue;
        }

        if (order.isTakeawayEmployee) {
          employeeMetrics.update(order.employeeName, (value) {
            value['totalOrders'] += 1;
            value['totalRevenue'] += order.totalAmount;
            value['employeeRevenue'] +=
                (order.totalAmount * takeawayPercentage / 100);
            return value;
          }, ifAbsent: () {
            return {
              'employeeName': order.employeeName,
              'totalOrders': 1,
              'totalRevenue': order.totalAmount,
              'employeeRevenue': (order.totalAmount * takeawayPercentage / 100),
            };
          });
        }
      }

      final sortedEmployees = employeeMetrics.values.toList()
        ..sort((a, b) => b['totalRevenue'].compareTo(a['totalRevenue']));

      final newEmployeesList = sortedEmployees.map((employee) {
        return TakeawayEmployeeReport(
          employeeName: employee['employeeName'],
          totalOrders: employee['totalOrders'],
          totalRevenue: employee['totalRevenue'],
          employeeRevenue: employee['employeeRevenue'],
        );
      }).toList();

      employeesList.assignAll(newEmployeesList);
      totalEmployeesCount = employeesList.length;
      updateEmployeesTable.value++;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  void fetchMostOrderedItems() {
    try {
      Map<String, dynamic> itemMetrics = {};

      for (var order in ordersList) {
        if (order.status == OrderStatus.active ||
            order.status == OrderStatus.canceled) {
          continue;
        }

        final totalSubtotal = order.subtotalAmount;
        if (totalSubtotal == 0) continue;

        for (var item in order.items) {
          final itemSubtotal = item.price * item.quantity;

          double originalRevenue = itemSubtotal;
          double originalProfit = (item.price - item.costPrice) * item.quantity;

          double itemDiscountShare = 0.0;
          if (order.discountAmount > 0) {
            itemDiscountShare =
                (itemSubtotal / totalSubtotal) * order.discountAmount;
          }

          final adjustedRevenue = itemSubtotal - itemDiscountShare;
          final adjustedPricePerItem = adjustedRevenue / item.quantity;
          final adjustedProfit =
              (adjustedPricePerItem - item.costPrice) * item.quantity;
          final costPriceTotal = item.costPrice * item.quantity;

          if (itemMetrics.containsKey(item.itemId)) {
            itemMetrics[item.itemId]['totalOrders'] += item.quantity;
            itemMetrics[item.itemId]['originalRevenue'] += originalRevenue;
            itemMetrics[item.itemId]['originalProfit'] += originalProfit;
            itemMetrics[item.itemId]['totalRevenue'] += adjustedRevenue;
            itemMetrics[item.itemId]['totalProfit'] += adjustedProfit;
            itemMetrics[item.itemId]['totalCostPrice'] += costPriceTotal;
          } else {
            itemMetrics[item.itemId] = {
              'itemId': item.itemId,
              'name': item.name,
              'totalOrders': item.quantity,
              'originalRevenue': originalRevenue,
              'originalProfit': originalProfit,
              'totalRevenue': adjustedRevenue,
              'totalProfit': adjustedProfit,
              'totalCostPrice': costPriceTotal,
              'usedProducts': {},
            };
          }

          for (var recipeItem in item.selectedSize.recipe) {
            itemMetrics[item.itemId]['usedProducts']
                .update(recipeItem.productId, (value) {
              value['quantity'] += recipeItem.quantity * item.quantity;
              return value;
            }, ifAbsent: () {
              return {
                'productName': recipeItem.productName,
                'quantity': recipeItem.quantity * item.quantity,
                'measuringUnit': recipeItem.measuringUnit.name,
              };
            });
          }

          for (var option in item.selectedOptions) {
            for (var recipeItem in option.recipe) {
              itemMetrics[item.itemId]['usedProducts']
                  .update(recipeItem.productId, (value) {
                value['quantity'] += recipeItem.quantity * item.quantity;
                return value;
              }, ifAbsent: () {
                return {
                  'productName': recipeItem.productName,
                  'quantity': recipeItem.quantity * item.quantity,
                  'measuringUnit': recipeItem.measuringUnit.name,
                };
              });
            }
          }
        }
      }

      final sortedItems = itemMetrics.values.toList()
        ..sort((a, b) => b['totalOrders'] - a['totalOrders']);

      final newItemsList = sortedItems.map((item) {
        return ItemReport(
          itemId: item['itemId'],
          name: item['name'],
          totalOrders: item['totalOrders'],
          originalRevenue: item['originalRevenue'],
          originalProfit: item['originalProfit'],
          totalRevenue: item['totalRevenue'],
          totalProfit: item['totalProfit'],
          totalCostPrice: item['totalCostPrice'],
          usedProducts:
              (Map<String, dynamic>.from(item['usedProducts'] as Map)).map(
            (key, value) => MapEntry(
              key,
              ProductUsage(
                productId: key,
                productName: value['productName'],
                quantity: value['quantity'],
                measuringUnit: value['measuringUnit'],
              ),
            ),
          ),
        );
      }).toList();
      itemsList.assignAll(newItemsList);
      totalItemsCount = itemsList.length;
      updateItemsTable.value++;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  void fetchTopUsedInventoryProducts() {
    try {
      Map<String, dynamic> inventoryMetrics = {};

      for (var order in ordersList) {
        for (var item in order.items) {
          for (var recipeItem in item.selectedSize.recipe) {
            inventoryMetrics.update(recipeItem.productId, (value) {
              value['totalQuantity'] += recipeItem.quantity * item.quantity;
              return value;
            }, ifAbsent: () {
              return {
                'productName': recipeItem.productName,
                'totalQuantity': recipeItem.quantity * item.quantity,
                'measuringUnit': recipeItem.measuringUnit.name,
              };
            });
          }
          for (var option in item.selectedOptions) {
            for (var recipeItem in option.recipe) {
              inventoryMetrics.update(recipeItem.productId, (value) {
                value['totalQuantity'] += recipeItem.quantity * item.quantity;
                return value;
              }, ifAbsent: () {
                return {
                  'productName': recipeItem.productName,
                  'totalQuantity': recipeItem.quantity * item.quantity,
                  'measuringUnit': recipeItem.measuringUnit.name,
                };
              });
            }
          }
        }
      }

      final sortedInventory = inventoryMetrics.values.toList()
        ..sort((a, b) => b['totalQuantity'] - a['totalQuantity']);

      final newInventoryList = sortedInventory.map((product) {
        return InventoryReport(
          productName: product['productName'],
          totalQuantity: product['totalQuantity'],
          measuringUnit: product['measuringUnit'],
        );
      }).toList();

      productsList.assignAll(newInventoryList);
      totalProductsCount = productsList.length;
      updateProductsTable.value++;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  @override
  void onClose() {
    salesRefreshController.dispose();
    takeawayPercentListener.cancel();
    ordersListener?.cancel();
    super.onClose();
  }
}

class AvailableShift {
  final String shiftId;
  final DateTime openingTime;

  AvailableShift({required this.shiftId, required this.openingTime});

  @override
  String toString() {
    return DateFormat(
            'MMM dd, yyyy, hh:mm a', isLangEnglish() ? 'en_US' : 'ar_SA')
        .format(openingTime);
  }
}

class ItemReport {
  final String itemId;
  final String name;
  final int totalOrders;
  final double originalRevenue;
  final double originalProfit;
  final double totalRevenue;
  final double totalProfit;
  final double totalCostPrice;
  final Map<String, ProductUsage> usedProducts;

  ItemReport({
    required this.itemId,
    required this.name,
    required this.totalOrders,
    required this.originalRevenue,
    required this.originalProfit,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalCostPrice,
    required this.usedProducts,
  });
}

class ProductUsage {
  final String productId;
  final String productName;
  final String measuringUnit;
  final int quantity;

  ProductUsage({
    required this.productId,
    required this.productName,
    required this.measuringUnit,
    required this.quantity,
  });
}

class InventoryReport {
  final String productName;
  final int totalQuantity;
  final String measuringUnit;
  InventoryReport({
    required this.productName,
    required this.measuringUnit,
    required this.totalQuantity,
  });
}

class TakeawayEmployeeReport {
  final String employeeName;
  final int totalOrders;
  final double totalRevenue;
  final double employeeRevenue;
  TakeawayEmployeeReport({
    required this.employeeName,
    required this.totalOrders,
    required this.totalRevenue,
    required this.employeeRevenue,
  });
}
