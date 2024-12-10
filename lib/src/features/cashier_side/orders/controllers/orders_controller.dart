import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/controllers/main_screen_controller.dart';
import '../../tables/components/models.dart';
import '../screens/order_screen.dart';
import '../screens/order_screen_phone.dart';

class OrdersController extends GetxController {
  static OrdersController get instance => Get.find();
  List<OrderModel> ordersList = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrdersList = <OrderModel>[].obs;
  final loadingOrders = true.obs;
  final Rxn<OrderStatus> selectedStatus = Rxn<OrderStatus>(null);
  final ordersRefreshController = RefreshController(initialRefresh: false);
  late DateTime? dateFrom;
  late DateTime? dateTo;
  String currentSelectedDate = 'today'.tr;
  final RxMap<String, Map<String, DateTime>> dateRangeOptions =
      <String, Map<String, DateTime>>{}.obs;
  final SingleSelectController<String?> dateSelectController =
      SingleSelectController<String?>('today'.tr);
  final SingleSelectController<String?> statusSelectController =
      SingleSelectController<String?>('active'.tr);
  StreamSubscription? ordersListener;
  final Rxn<OrderModel?> currentChosenOrder = Rxn<OrderModel>(null);
  String searchText = '';

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    selectedStatus.value = OrderStatus.active;
    _initializeDateRangeOptions();
    _listenToFilteredOrders();
  }

  @override
  void onClose() {
    ordersListener?.cancel();
    dateSelectController.dispose();
    super.onClose();
  }

  void updateDateFilters() {
    _initializeDateRangeOptions();
    resetDateFilter();
  }

  void onOrderTap({required int chosenIndex, required bool isPhone}) {
    final chosenOrder = filteredOrdersList[chosenIndex];
    if (currentChosenOrder.value == chosenOrder) {
      currentChosenOrder.value = null;
      MainScreenController.instance.showNewOrderButton.value = true;
    } else {
      if (chosenOrder.status == OrderStatus.active) {
        Get.to(
          () => isPhone
              ? OrderScreenPhone(
                  orderModel: chosenOrder,
                )
              : OrderScreen(
                  orderModel: chosenOrder,
                ),
          transition: Transition.noTransition,
        );
      } else {
        currentChosenOrder.value = chosenOrder;
        MainScreenController.instance.showNewOrderButton.value = false;
      }
    }
  }

  void _initializeDateRangeOptions() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Adjust the start of the week to Saturday
    final daysSinceSaturday =
        (now.weekday % 7); // Saturday is 0 when using modulo 7
    final startOfThisWeek =
        todayStart.subtract(Duration(days: daysSinceSaturday));
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
  }

  void setStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
    _listenToFilteredOrders();
  }

  void applyPredefinedDateRange(String? key, BuildContext context) async {
    try {
      if (key != null) {
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
              String dateFormatted =
                  DateFormat('MMM dd, yyyy').format(dateFrom!);
              dateTo = DateTime(results.last!.year, results.last!.month,
                  results.last!.day, 23, 59, 59);
              if (dateFrom!.day != dateTo!.day) {
                dateFormatted +=
                    ' - ${DateFormat('MMM dd, yyyy').format(dateTo!)}';
              }
              if (isDate(currentSelectedDate)) {
                dateRangeOptions.remove(currentSelectedDate);
              }
              currentSelectedDate = dateFormatted;
              dateSelectController.value = dateFormatted;
              dateRangeOptions[dateFormatted] = {
                "from": dateFrom!,
                "to": dateTo!,
              };
              _listenToFilteredOrders();
            }
          } else {
            resetDateFilter();
          }
        } else {
          final selectedRange = dateRangeOptions[key];
          if (selectedRange != null) {
            dateFrom = selectedRange["from"];
            dateTo = selectedRange["to"];
            _listenToFilteredOrders();
            if (isDate(currentSelectedDate)) {
              dateRangeOptions.remove(currentSelectedDate);
            }
            currentSelectedDate = key;
          }
        }
      }
    } catch (error) {
      AppInit.logger.e(error.toString());
      resetDateFilter();
    }
  }

  void resetDateFilter() {
    if (isDate(currentSelectedDate) &&
        dateRangeOptions.containsKey(currentSelectedDate)) {
      dateRangeOptions.remove(currentSelectedDate);
    }
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, now.day);
    dateTo = DateTime(now.year, now.month, now.day, 23, 59, 59);
    dateSelectController.value = 'today'.tr;
    _listenToFilteredOrders();
    currentChosenOrder.value = null;
  }

  void onRefresh() {
    loadingOrders.value = true;
    currentChosenOrder.value = null;
    _listenToFilteredOrders();
    ordersRefreshController.refreshToIdle();
    ordersRefreshController.resetNoData();
  }

  bool isDate(String input) {
    final yearRegex = RegExp(r'\b(?:\d{4}|[٠-٩]{4})\b');
    return yearRegex.hasMatch(input);
  }

  void onOrderStatusChanged(value) {
    statusSelectController.value = value;
    setStatusFilter(mapStringToOrderStatus(value));
  }

  OrderStatus? mapStringToOrderStatus(String value) {
    return value == 'active'.tr
        ? OrderStatus.active
        : value == 'completed'.tr
            ? OrderStatus.complete
            : value == 'canceled'.tr
                ? OrderStatus.canceled
                : value == 'returned'.tr
                    ? OrderStatus.returned
                    : null;
  }

  void _listenToFilteredOrders() {
    try {
      loadingOrders.value = true;
      ordersList = [];
      filteredOrdersList.value = [];
      ordersListener?.cancel();

      final CollectionReference ordersRef =
          FirebaseFirestore.instance.collection('orders');
      Query query = ordersRef;

      if (selectedStatus.value != null) {
        query = query.where('status', isEqualTo: selectedStatus.value!.name);
      }

      if (dateFrom != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom!));
      }

      if (dateTo != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(dateTo!));
      }

      ordersListener = query.snapshots().listen((snapshot) {
        final List<OrderModel> updatedOrders = snapshot.docs.map((doc) {
          return OrderModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        updatedOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        ordersList = updatedOrders;
        loadingOrders.value = false;
        if (searchText.isEmpty) {
          filteredOrdersList.value = ordersList;
        } else {
          onOrdersSearch();
        }
      });
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
  }

  void onOrdersSearch() {
    if (!loadingOrders.value) {
      final searchedByIdList = ordersList
          .where((order) => order.orderId
              .toUpperCase()
              .contains(searchText.toUpperCase().trim()))
          .toList();
      filteredOrdersList.value =
          searchText.trim().isEmpty ? ordersList : searchedByIdList;
    }
  }

  void onReopenOrderTap({required bool isPhone}) async {
    showLoadingScreen();
    final orderModel = currentChosenOrder.value!;
    late List<TableModel> tablesList;

    // Fetch all tables
    final tablesListGet = await getTables();
    if (tablesListGet != null) {
      tablesList = tablesListGet;
    } else {
      hideLoadingScreen();
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    tablesList = tablesList.where((table) {
      return orderModel.tableNumbers!.contains(table.number);
    }).toList();

    for (var table in tablesList) {
      if (table.currentOrderId != null &&
          table.currentOrderId != orderModel.orderId &&
          (table.status == TableStatus.occupied ||
              table.status == TableStatus.billed)) {
        hideLoadingScreen();
        showSnackBar(
          text: 'conflictingTablesError'.tr,
          snackBarType: SnackBarType.error,
        );
        return;
      }
    }

    // Proceed with reopening the order
    final reopenOrderStatus =
        await reopenOrder(orderId: orderModel.orderId, tablesList: tablesList);

    hideLoadingScreen();
    if (reopenOrderStatus == FunctionStatus.success) {
      currentChosenOrder.value = null;
      Get.back();
      Get.to(
        () => isPhone
            ? OrderScreenPhone(
                orderModel: orderModel,
                tablesIds: orderModel.tableNumbers != null
                    ? tablesList
                        .where((table) =>
                            orderModel.tableNumbers!.contains(table.number))
                        .map((table) => table.tableId)
                        .toList()
                    : [],
              )
            : OrderScreen(
                orderModel: orderModel,
                tablesIds: orderModel.tableNumbers != null
                    ? tablesList
                        .where((table) =>
                            orderModel.tableNumbers!.contains(table.number))
                        .map((table) => table.tableId)
                        .toList()
                    : [],
              ),
        transition: Transition.noTransition,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> reopenOrder(
      {required String orderId, required List<TableModel> tablesList}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.update(firestore.collection('orders').doc(orderId), {
        'status': OrderStatus.active.name,
      });
      for (var table in tablesList) {
        batch.update(firestore.collection('tables').doc(table.tableId), {
          'status': TableStatus.occupied.name,
          'currentOrderId': orderId,
        });
      }
      await batch.commit();
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<List<TableModel>?> getTables() async {
    try {
      final CollectionReference tablesRef =
          FirebaseFirestore.instance.collection('tables');
      final tablesSnapshot = await tablesRef.get();
      List<TableModel> tablesList = tablesSnapshot.docs.map((doc) {
        return TableModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      tablesList.sort((a, b) => a.number.compareTo(b.number));
      return tablesList;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return null;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return null;
    }
  }

  Future<OrderModel?> getOrder({required String orderId}) async {
    try {
      final orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();
      if (orderSnapshot.exists) {
        final orderModel =
            OrderModel.fromFirestore(orderSnapshot.data()!, orderSnapshot.id);
        return orderModel;
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
    return null;
  }

  void returnOrderTap() async {
    showLoadingScreen();
    final returnOrderStatus = await returnOrder();
    hideLoadingScreen();
    if (returnOrderStatus == FunctionStatus.success) {
      showSnackBar(
        text: 'orderReturnedSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
      currentChosenOrder.value = null;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> returnOrder() async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(currentChosenOrder.value!.orderId);
      await orderReference.update({'status': OrderStatus.returned.name});
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
    return FunctionStatus.failure;
  }

  void completeOrderTap() async {
    showLoadingScreen();
    final completeOrderStatus = await completeOrder();
    hideLoadingScreen();
    if (completeOrderStatus == FunctionStatus.success) {
      showSnackBar(
        text: 'orderCompletedSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
      currentChosenOrder.value = null;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> completeOrder() async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(currentChosenOrder.value!.orderId);
      await orderReference.update({'status': OrderStatus.complete.name});
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
    return FunctionStatus.failure;
  }

  void printOrderTap() {
    showSnackBar(
      text: 'orderPrintSuccess'.tr,
      snackBarType: SnackBarType.success,
    );
  }
}
