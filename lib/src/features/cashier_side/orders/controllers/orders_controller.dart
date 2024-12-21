import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/controllers/main_screen_controller.dart';
import '../../tables/components/models.dart';
import '../screens/order_details_screen_phone.dart';
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
  final RxInt currentSelectedDate = 0.obs;
  final RxInt currentSelectedStatus = 0.obs;
  final RxMap<String, Map<String, DateTime>> dateRangeOptions =
      <String, Map<String, DateTime>>{}.obs;
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
    super.onClose();
  }

  void updateDateFilters() {
    _initializeDateRangeOptions();
  }

  void updateNewDayDateFilters() {
    _initializeDateRangeOptions();
    _listenToFilteredOrders();
  }

  void onOrderTap({required int chosenIndex, required bool isPhone}) {
    final chosenOrder = filteredOrdersList[chosenIndex];
    if (isPhone) {
      if (chosenOrder.status == OrderStatus.active) {
        Get.to(
          () => OrderScreenPhone(orderModel: chosenOrder),
          transition: getPageTransition(),
        );
      } else {
        Get.to(
          () => OrderDetailsScreenPhone(
            orderModel: chosenOrder,
            controller: this,
          ),
          transition: getPageTransition(),
        );
      }
    } else {
      if (currentChosenOrder.value == chosenOrder) {
        currentChosenOrder.value = null;
        MainScreenController.instance.showNewOrderButton.value = true;
      } else {
        if (chosenOrder.status == OrderStatus.active) {
          Get.to(
            () => OrderScreen(orderModel: chosenOrder),
            transition: Transition.noTransition,
          );
        } else {
          currentChosenOrder.value = chosenOrder;
          MainScreenController.instance.showNewOrderButton.value = false;
        }
      }
    }
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

  void setStatusFilter(OrderStatus? status) {
    selectedStatus.value = status;
    _listenToFilteredOrders();
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
    final normalizedInput = input.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 0x0660).toString(),
    );
    return yearRegex.hasMatch(normalizedInput);
  }

  void onOrderStatusChanged(String value, index) {
    if (index != currentSelectedStatus.value) {
      currentSelectedStatus.value = index;
      setStatusFilter(mapStringToOrderStatus(value));
    }
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

  void onReopenOrderTap(
      {required bool isPhone, OrderModel? aOrderModel}) async {
    showLoadingScreen();
    final orderModel = isPhone ? aOrderModel! : currentChosenOrder.value!;
    late List<TableModel> tablesList;
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
          table.status == TableStatus.occupied) {
        hideLoadingScreen();
        showSnackBar(
          text: 'conflictingTablesError'.tr,
          snackBarType: SnackBarType.error,
        );
        return;
      }
    }
    final reopenOrderStatus =
        await reopenOrder(orderId: orderModel.orderId, tablesList: tablesList);

    hideLoadingScreen();
    if (reopenOrderStatus == FunctionStatus.success) {
      currentChosenOrder.value = null;
      if (isPhone) Get.back();
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

  void returnOrderTap({required bool isPhone, OrderModel? orderModel}) async {
    showLoadingScreen();
    final returnOrderStatus =
        await returnOrder(isPhone: isPhone, orderModel: orderModel);
    hideLoadingScreen();
    if (returnOrderStatus == FunctionStatus.success) {
      if (isPhone) {
        Get.back();
      } else {
        currentChosenOrder.value = null;
      }
      showSnackBar(
        text: 'orderReturnedSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> returnOrder(
      {required bool isPhone, OrderModel? orderModel}) async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(isPhone
              ? orderModel!.orderId
              : currentChosenOrder.value!.orderId);
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

  void completeOrderTap({required bool isPhone, OrderModel? orderModel}) async {
    showLoadingScreen();
    final completeOrderStatus =
        await completeOrder(isPhone: isPhone, orderModel: orderModel);
    hideLoadingScreen();
    if (completeOrderStatus == FunctionStatus.success) {
      if (isPhone) Get.back();
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

  Future<FunctionStatus> completeOrder(
      {required bool isPhone, OrderModel? orderModel}) async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(isPhone
              ? orderModel!.orderId
              : currentChosenOrder.value!.orderId);
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

  void printOrderTap(
      {required bool isPhone, required OrderModel orderModel}) async {
    showLoadingScreen();
    final printStatus = await chargeOrderPrinter(
        order: orderModel,
        employeeName: AuthenticationRepository.instance.employeeInfo?.name,
        openDrawer: false);
    hideLoadingScreen();
    if (printStatus == FunctionStatus.success) {
      showSnackBar(
        text: 'orderPrintSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
          text: 'receiptPrintFailed'.tr, snackBarType: SnackBarType.warning);
    }
  }
}
