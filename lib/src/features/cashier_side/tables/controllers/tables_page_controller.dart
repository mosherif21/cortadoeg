import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/components/billed_selection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../../orders/components/models.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';
import '../components/billed_selection_phone.dart';
import '../components/models.dart';

class TablesPageController extends GetxController {
  static TablesPageController get instance => Get.find();
  final RxList<TableModel> tablesList = <TableModel>[].obs;
  final RxList<int> selectedTables = <int>[].obs;
  final loadingTables = true.obs;
  late final StreamSubscription selectedTablesListener;
  late final StreamSubscription tablesListener;
  bool navBarAccess = true;
  final tablesRefreshController = RefreshController(initialRefresh: false);
  @override
  void onInit() async {
    //
    super.onInit();
  }

  void onRefresh() {
    loadingTables.value = true;
    loadTables();
    tablesRefreshController.refreshToIdle();
    tablesRefreshController.resetNoData();
  }

  Future<List<TableModel>?> fetchTables() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('tables').get();
      final tables = querySnapshot.docs.map((doc) {
        return TableModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      tables.sort((a, b) => a.number.compareTo(b.number));
      return tables;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return null;
    }
    return null;
  }

  void loadTables() async {
    final tables = await fetchTables();
    if (tables != null) {
      tablesList.value = tables;
      loadingTables.value = false;
      for (TableModel table in tables) {
        if (selectedTables.contains(table.number) &&
            table.status != TableStatus.available) {
          selectedTables.remove(table.number);
        }
      }
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  void onReady() {
    tablesListener = listenToTables().listen((tables) {
      tablesList.value = tables;
      loadingTables.value = false;
      for (TableModel table in tables) {
        if (selectedTables.contains(table.number) &&
            table.status != TableStatus.available) {
          selectedTables.remove(table.number);
        }
      }
    });
    selectedTablesListener = selectedTables.listen((tablesList) {
      final mainScreenController = MainScreenController.instance;
      if (selectedTables.isNotEmpty && navBarAccess) {
        mainScreenController.showNewOrderButton.value = false;
      } else if (selectedTables.isEmpty && navBarAccess) {
        mainScreenController.showNewOrderButton.value = true;
      }
    });
    super.onReady();
  }

  void switchTables(int fromTableNo, int toTableNo) async {
    showLoadingScreen();
    final fromTable = tablesList[fromTableNo - 1];
    final toTable = tablesList[toTableNo - 1];
    final switchStatus =
        await switchTableNumbers(fromTable: fromTable, toTable: toTable);
    hideLoadingScreen();
    if (switchStatus == FunctionStatus.success) {
      if (selectedTables.contains(fromTableNo) ||
          selectedTables.contains(toTableNo)) {
        if (fromTable.status == TableStatus.available) {
          selectedTables.remove(fromTableNo);
          selectedTables.add(toTableNo);
        } else {
          selectedTables.remove(toTableNo);
          selectedTables.add(fromTableNo);
        }
      }
      showSnackBar(
        text: 'tablesOrdersSwitched'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> switchTableNumbers({
    required TableModel fromTable,
    required TableModel toTable,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      if (fromTable.currentOrderId == null && toTable.currentOrderId == null) {
        return FunctionStatus.failure;
      }

      final batch = firestore.batch();
      DocumentSnapshot<Map<String, dynamic>>? fromOrderSnapshot;
      DocumentSnapshot<Map<String, dynamic>>? toOrderSnapshot;

      if (fromTable.currentOrderId != null) {
        fromOrderSnapshot = await firestore
            .collection('orders')
            .doc(fromTable.currentOrderId)
            .get();
      }

      if (toTable.currentOrderId != null) {
        toOrderSnapshot = await firestore
            .collection('orders')
            .doc(toTable.currentOrderId)
            .get();
      }
      final fromTableStatus = fromTable.status;
      final fromTableOrderId = fromTable.currentOrderId;
      final toTableStatus = toTable.status;
      final toTableOrderId = toTable.currentOrderId;

      final updatedFromTable = TableModel(
        tableId: fromTable.tableId,
        number: fromTable.number,
        status: toTableStatus,
        currentOrderId: toTableOrderId,
      );

      final updatedToTable = TableModel(
        tableId: toTable.tableId,
        number: toTable.number,
        status: fromTableStatus,
        currentOrderId: fromTableOrderId,
      );
      batch.update(
        firestore.collection('tables').doc(fromTable.tableId),
        updatedFromTable.toFirestore(),
      );
      batch.update(
        firestore.collection('tables').doc(toTable.tableId),
        updatedToTable.toFirestore(),
      );
      if (fromOrderSnapshot?.exists == true &&
          toOrderSnapshot?.exists == true) {
        final fromOrderData = fromOrderSnapshot!.data()!;
        final toOrderData = toOrderSnapshot!.data()!;

        List<int> fromTableNumbers =
            List<int>.from(fromOrderData['tableNumbers'] ?? []);
        List<int> toTableNumbers =
            List<int>.from(toOrderData['tableNumbers'] ?? []);
        if (fromTableNumbers.contains(fromTable.number)) {
          fromTableNumbers.remove(fromTable.number);
          toTableNumbers.add(fromTable.number);
        }

        if (toTableNumbers.contains(toTable.number)) {
          toTableNumbers.remove(toTable.number);
          fromTableNumbers.add(toTable.number);
        }
        batch.update(
            fromOrderSnapshot.reference, {'tableNumbers': fromTableNumbers});
        batch.update(
            toOrderSnapshot.reference, {'tableNumbers': toTableNumbers});
      } else if (fromOrderSnapshot?.exists == true) {
        final fromOrderData = fromOrderSnapshot!.data()!;
        List<int> fromTableNumbers =
            List<int>.from(fromOrderData['tableNumbers'] ?? []);

        if (fromTableNumbers.contains(fromTable.number)) {
          fromTableNumbers.remove(fromTable.number);
          fromTableNumbers.add(toTable.number);

          batch.update(
              fromOrderSnapshot.reference, {'tableNumbers': fromTableNumbers});
        }
      } else if (toOrderSnapshot?.exists == true) {
        final toOrderData = toOrderSnapshot!.data()!;
        List<int> toTableNumbers =
            List<int>.from(toOrderData['tableNumbers'] ?? []);

        if (toTableNumbers.contains(toTable.number)) {
          toTableNumbers.remove(toTable.number);
          toTableNumbers.add(fromTable.number);

          batch.update(
              toOrderSnapshot.reference, {'tableNumbers': toTableNumbers});
        }
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

  bool acceptSwitchTable(int fromTableNo, int toTableNo) {
    if (fromTableNo == toTableNo) {
      return false;
    }
    final fromTable = tablesList[fromTableNo - 1];
    final toTable = tablesList[toTableNo - 1];
    final noOrderToSwitch =
        fromTable.currentOrderId == null && toTable.currentOrderId == null;
    final sameOrder = fromTable.currentOrderId == toTable.currentOrderId;
    final tableUnavailable = fromTable.status == TableStatus.unavailable ||
        toTable.status == TableStatus.unavailable;
    if (noOrderToSwitch) {
      showSnackBar(
          text: 'noOrderToSwitch'.tr, snackBarType: SnackBarType.error);
      return false;
    } else if (sameOrder) {
      showSnackBar(
          text: 'tableSameOrderId'.tr, snackBarType: SnackBarType.success);
      return false;
    } else if (tableUnavailable) {
      showSnackBar(
          text: 'tableUnavailable'.tr, snackBarType: SnackBarType.error);
      return false;
    } else {
      return true;
    }
  }

  void onTableSelected(int tableIndex, bool isPhone) async {
    final tableStatus = tablesList[tableIndex].status;
    if (selectedTables.contains(tableIndex + 1)) {
      selectedTables.remove(tableIndex + 1);
    } else if (tableStatus == TableStatus.available) {
      selectedTables.add(tableIndex + 1);
    } else if (tableStatus == TableStatus.occupied && selectedTables.isEmpty) {
      showLoadingScreen();
      final currentOrderID = tablesList[tableIndex].currentOrderId;
      if (currentOrderID != null) {
        final orderModel = await getOrder(orderId: currentOrderID);
        hideLoadingScreen();
        if (orderModel != null) {
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
                        : null,
                  )
                : OrderScreen(
                    orderModel: orderModel,
                    tablesIds: orderModel.tableNumbers != null
                        ? tablesList
                            .where((table) =>
                                orderModel.tableNumbers!.contains(table.number))
                            .map((table) => table.tableId)
                            .toList()
                        : null,
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
    } else if (tableStatus == TableStatus.billed && selectedTables.isEmpty) {
      final screenType = GetScreenType(Get.context!);
      final table = tablesList[tableIndex];
      screenType.isPhone
          ? showRegularBottomSheet(
              BilledSelectionPhone(
                tableIsEmptyPress: () =>
                    onTableEmptyTap(orderId: table.currentOrderId!),
                reopenOrderPress: () => onReopenOrderTap(
                    orderId: table.currentOrderId!, isPhone: isPhone),
              ),
            )
          : showDialog(
              context: Get.context!,
              builder: (BuildContext context) {
                return BilledSelection(
                  tableIsEmptyPress: () =>
                      onTableEmptyTap(orderId: table.currentOrderId!),
                  reopenOrderPress: () => onReopenOrderTap(
                      orderId: table.currentOrderId!, isPhone: isPhone),
                );
              },
            );
    } else if (tableStatus == TableStatus.unavailable &&
        selectedTables.isEmpty) {
      return;
    } else {
      showSnackBar(
          text: 'tableUnavailable'.tr, snackBarType: SnackBarType.error);
    }
  }

  void onTableEmptyTap({required String orderId}) async {
    showLoadingScreen();
    final assignTableEmptyStatus = await assignTableEmpty(orderId: orderId);
    hideLoadingScreen();
    if (assignTableEmptyStatus == FunctionStatus.success) {
      Get.back();
      showSnackBar(
        text: 'tableEmptySuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> assignTableEmpty({required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      for (var table in tablesList.where((table) {
        return table.currentOrderId == orderId;
      })) {
        batch.update(firestore.collection('tables').doc(table.tableId), {
          'status': TableStatus.available.name,
          'currentOrderId': null,
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

  void onReopenOrderTap(
      {required String orderId, required bool isPhone}) async {
    showLoadingScreen();
    final orderModel = await reopenOrder(orderId: orderId);
    hideLoadingScreen();
    if (orderModel != null) {
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
                    : null,
              )
            : OrderScreen(
                orderModel: orderModel,
                tablesIds: orderModel.tableNumbers != null
                    ? tablesList
                        .where((table) =>
                            orderModel.tableNumbers!.contains(table.number))
                        .map((table) => table.tableId)
                        .toList()
                    : null,
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

  Future<OrderModel?> reopenOrder({required String orderId}) async {
    try {
      final orderModel = await getOrder(orderId: orderId);
      if (orderModel != null) {
        final firestore = FirebaseFirestore.instance;
        final batch = firestore.batch();
        batch.update(firestore.collection('orders').doc(orderId), {
          'status': OrderStatus.active.name,
        });
        for (var table in tablesList.where((table) {
          return table.currentOrderId == orderId;
        })) {
          batch.update(firestore.collection('tables').doc(table.tableId), {
            'status': TableStatus.occupied.name,
            'currentOrderId': orderId,
          });
        }
        await batch.commit();
        return orderModel;
      }
      return null;
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

  Stream<List<TableModel>> listenToTables() {
    final CollectionReference tablesRef =
        FirebaseFirestore.instance.collection('tables');
    return tablesRef.snapshots().map((snapshot) {
      List<TableModel> tables = snapshot.docs.map((doc) {
        return TableModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      tables.sort((a, b) => a.number.compareTo(b.number));
      return tables;
    });
  }

  @override
  void onClose() async {
    selectedTablesListener.cancel();
    tablesListener.cancel();
    tablesRefreshController.dispose();
    super.onClose();
  }

  void onBackPressed() {
    if (selectedTables.isNotEmpty) selectedTables.value = [];
    Get.back();
  }

  onNewOrder({required bool isPhone}) async {
    showLoadingScreen();
    final newOrderModel =
        await addTableOrder(orderTables: selectedTables.toList());
    hideLoadingScreen();
    if (newOrderModel != null) {
      selectedTables.value = [];
      navigateToOrderScreen(isPhone, newOrderModel);
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<OrderModel?> addTableOrder(
      {required List<int> orderTables, bool isTakeaway = false}) async {
    try {
      final orderNumber = await generateOrderNumber();
      if (orderNumber != null) {
        final firestore = FirebaseFirestore.instance;
        final orderDoc = firestore.collection('orders').doc();
        final newOrder = OrderModel(
          orderId: orderDoc.id,
          orderNumber: orderNumber,
          tableNumbers: orderTables,
          items: [],
          status: OrderStatus.active,
          timestamp: Timestamp.now(),
          totalAmount: 0.0,
          discountAmount: 0.0,
          subtotalAmount: 0.0,
          taxTotalAmount: 0.0,
          isTakeaway: isTakeaway,
        );
        await firestore.runTransaction((transaction) async {
          transaction.set(orderDoc, newOrder.toFirestore());
          for (int tableNo in orderTables) {
            final tableQuery = await firestore
                .collection('tables')
                .where('number', isEqualTo: tableNo)
                .limit(1)
                .get();
            if (tableQuery.docs.isNotEmpty) {
              final tableDoc = tableQuery.docs.first;
              final tableData = tableDoc.data();
              if (tableData['status'] == TableStatus.available.name) {
                transaction.update(tableDoc.reference, {
                  'status': TableStatus.occupied.name,
                  'currentOrderId': newOrder.orderId,
                });
              } else {
                showSnackBar(
                    text: 'tableNotAvailable'
                        .trParams({'tableNo': tableNo.toString()}),
                    snackBarType: SnackBarType.error);
              }
            } else {
              showSnackBar(
                  text: 'errorOccurred'.tr, snackBarType: SnackBarType.error);
            }
          }
        });
        return newOrder;
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print('FirebaseException: ${error.message}');
      }
    } catch (err) {
      if (kDebugMode) {
        print('Exception: ${err.toString()}');
      }
    }
    return null;
  }

  Future<int?> generateOrderNumber() async {
    try {
      final DateTime now = DateTime.now();

      final ordersRef = FirebaseFirestore.instance.collection('orders');
      final QuerySnapshot todayOrders = await ordersRef
          .where('timestamp',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(now.year, now.month, now.day)))
          .where('timestamp',
              isLessThan: Timestamp.fromDate(
                  DateTime(now.year, now.month, now.day + 1)))
          .get();

      final int orderCount = todayOrders.docs.length;
      return orderCount + 1;
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

  void navigateToOrderScreen(bool isPhone, OrderModel newOrder) {
    Get.to(
      () => isPhone
          ? OrderScreenPhone(
              orderModel: newOrder,
              tablesIds: newOrder.tableNumbers != null
                  ? tablesList
                      .where((table) =>
                          newOrder.tableNumbers!.contains(table.number))
                      .map((table) => table.tableId)
                      .toList()
                  : null,
            )
          : OrderScreen(
              orderModel: newOrder,
              tablesIds: newOrder.tableNumbers != null
                  ? tablesList
                      .where((table) =>
                          newOrder.tableNumbers!.contains(table.number))
                      .map((table) => table.tableId)
                      .toList()
                  : null,
            ),
      transition: Transition.noTransition,
    );
  }

  onTablesScreenPop() {
    if (!navBarAccess) {
      navBarAccess = true;
      if (selectedTables.isNotEmpty) selectedTables.value = [];
    }
  }
}
