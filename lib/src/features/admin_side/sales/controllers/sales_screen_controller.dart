import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  final profitChangePercentage = 0.0.obs;
  final completeOrderPercentage = 0.0.obs;
  final returnedOrderPercentage = 0.0.obs;
  final canceledOrderPercentage = 0.0.obs;
  final dineInOrdersPercentage = 0.0.obs;
  final takeawayOrdersPercentage = 0.0.obs;
  final RxBool loadingSales = true.obs;
  DocumentSnapshot? itemsLastDocument;
  DocumentSnapshot? productsLastDocument;
  late final GlobalKey<AsyncPaginatedDataTable2State> itemsTableKey;
  late final GlobalKey<AsyncPaginatedDataTable2State> productsTableKey;
  final int rowsPerPage = 8;
  int totalItemsCount = 0;
  int totalProductsCount = 0;
  List<ItemReport> itemsList = [];
  List<InventoryReport> productsList = [];

  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    itemsTableKey = GlobalKey<AsyncPaginatedDataTable2State>();
    productsTableKey = GlobalKey<AsyncPaginatedDataTable2State>();
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _initializeDateRangeOptions();
    fetchGeneralSales();
  }

  Future<void> fetchTopUsedInventoryProducts({
    int start = 0,
    int limit = 8,
  }) async {
    try {
      Map<String, dynamic> inventoryMetrics = {};
      Query query = _firestore
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: dateFrom)
          .where('timestamp', isLessThanOrEqualTo: dateTo)
          .where('status', isNotEqualTo: 'active');
      if (start == 0) {
        final countSnapshot = await query.count().get();
        totalItemsCount = countSnapshot.count ?? 0;
        itemsLastDocument = null;
      } else if (itemsLastDocument != null) {
        query = query.startAfterDocument(itemsLastDocument!);
      } else {
        return;
      }
      final querySnapshot = await query.limit(limit).get();
      if (querySnapshot.docs.isEmpty) {
        if (start == 0) {
          productsList.clear();
        }
        return;
      }
      itemsLastDocument = querySnapshot.docs.last;

      for (var doc in querySnapshot.docs) {
        final order = OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
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

      if (start == 0) {
        productsList.assignAll(newInventoryList);
      } else {
        productsList.addAll(newInventoryList);
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  Future<void> fetchMostOrderedItems({
    int start = 0,
    int limit = 8,
  }) async {
    try {
      Map<String, dynamic> itemMetrics = {};
      Query query = _firestore
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: dateFrom)
          .where('timestamp', isLessThanOrEqualTo: dateTo)
          .where('status', isNotEqualTo: 'active');
      if (start == 0) {
        final countSnapshot = await query.count().get();
        totalItemsCount = countSnapshot.count ?? 0;
        itemsLastDocument = null;
      } else if (itemsLastDocument != null) {
        query = query.startAfterDocument(itemsLastDocument!);
      } else {
        return;
      }
      final querySnapshot = await query.limit(limit).get();
      if (querySnapshot.docs.isEmpty) {
        if (start == 0) {
          itemsList.clear();
        }
        return;
      }
      itemsLastDocument = querySnapshot.docs.last;

      for (var doc in querySnapshot.docs) {
        final order = OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
        for (var item in order.items) {
          if (!itemMetrics.containsKey(item.itemId)) {
            itemMetrics[item.itemId] = {
              'itemId': item.itemId,
              'name': item.name,
              'totalOrders': 0,
              'totalRevenue': 0.0,
              'totalProfit': 0.0,
              'totalCostPrice': 0.0,
              'usedProducts': <String, dynamic>{}
            };
          }
          itemMetrics[item.itemId]['totalOrders'] += item.quantity;
          itemMetrics[item.itemId]['totalRevenue'] +=
              item.price * item.quantity;
          itemMetrics[item.itemId]['totalProfit'] +=
              (item.price - item.costPrice) * item.quantity;
          itemMetrics[item.itemId]['totalCostPrice'] +=
              item.costPrice * item.quantity;

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
                  'measuringUnit': recipeItem.measuringUnit,
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
          totalRevenue: item['totalRevenue'],
          totalProfit: item['totalProfit'],
          totalCostPrice: item['totalCostPrice'],
          usedProducts: (item['usedProducts'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key,
              ProductUsage(
                  productId: key,
                  productName: value['productName'],
                  quantity: value['quantity'],
                  measuringUnit: value['measuringUnit']),
            ),
          ),
        );
      }).toList();
      if (start == 0) {
        itemsList.assignAll(newItemsList);
      } else {
        itemsList.addAll(newItemsList);
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  void resetItemsTableValues() {
    itemsList.clear();
    itemsLastDocument = null;
    totalItemsCount = 0;
    itemsTableKey.currentState!.pageTo(0);
  }

  void resetProductsTableValues() {
    productsList.clear();
    productsLastDocument = null;
    totalProductsCount = 0;
    productsTableKey.currentState!.pageTo(0);
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
    fetchGeneralSales();
    resetItemsTableValues();
    resetProductsTableValues();
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
              resetItemsTableValues();
              resetProductsTableValues();
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
            resetItemsTableValues();
            resetProductsTableValues();
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
    resetItemsTableValues();
    resetProductsTableValues();
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
    resetItemsTableValues();
    resetProductsTableValues();
    salesRefreshController.refreshCompleted();
  }

  void fetchGeneralSales() async {
    try {
      loadingSales.value = true;
      final revenueQuery = await _fetchMetricsForDateRange(dateFrom, dateTo);
      final revenue = revenueQuery['revenue'];
      final orders = revenueQuery['orders'];
      final customers = revenueQuery['customers'];
      final costPrice = revenueQuery['costPrice'];
      final statusCounts = revenueQuery['statusCounts'];
      final dineInCount = revenueQuery['dineInCount'];
      final takeawayCount = revenueQuery['takeawayCount'];
      final profit = revenue - costPrice;
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
      loadingSales.value = false;
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

class ItemReport {
  final String itemId;
  final String name;
  final int totalOrders;
  final double totalRevenue;
  final double totalProfit;
  final double totalCostPrice;
  final Map<String, ProductUsage> usedProducts;

  ItemReport({
    required this.itemId,
    required this.name,
    required this.totalOrders,
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
