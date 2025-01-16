import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/tables/components/models.dart';

class ManageTablesPageController extends GetxController {
  static ManageTablesPageController get instance => Get.find();
  final RxList<TableModel> tablesList = <TableModel>[].obs;
  final Rxn<int> selectedTable = Rxn<int>(null);
  final Rxn<TableModel> selectedTableModel = Rxn<TableModel>(null);
  final loadingTables = true.obs;
  late final StreamSubscription tablesListener;
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
        if (selectedTable.value == table.number) {
          if (table.status == TableStatus.occupied) {
            selectedTable.value = null;
            selectedTableModel.value = null;
          } else {
            selectedTable.value = table.number;
            selectedTableModel.value = table;
          }
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
        if (selectedTable.value == table.number) {
          if (table.status == TableStatus.occupied) {
            selectedTable.value = null;
            selectedTableModel.value = null;
          } else {
            selectedTable.value = table.number;
            selectedTableModel.value = table;
          }
        }
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
      if (selectedTable.value != null) {
        if (selectedTable.value == fromTableNo ||
            selectedTable.value == toTableNo) {
          selectedTable.value = fromTable.status == TableStatus.available
              ? toTableNo
              : fromTableNo;
          selectedTableModel.value =
              fromTable.status == TableStatus.available ? toTable : fromTable;
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
    final tableNumber = tableIndex + 1;
    if (selectedTable.value == tableNumber) {
      selectedTable.value = null;
      selectedTableModel.value = null;
    } else if (tableStatus == TableStatus.available ||
        tableStatus == TableStatus.unavailable) {
      selectedTable.value = tableNumber;
      selectedTableModel.value = tablesList[tableIndex];
    } else if (tableStatus == TableStatus.occupied &&
        selectedTable.value == null) {
      showSnackBar(
        text: 'changeTableStatusDenied'.tr,
        snackBarType: SnackBarType.warning,
      );
    } else {
      showSnackBar(
        text: 'tableUnavailable'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void onSetUnavailableTap() async {
    showLoadingScreen();
    final onChangeTableStatus = await changeTableStatus(
        tableStatus: TableStatus.unavailable,
        tableId: selectedTableModel.value!.tableId);
    hideLoadingScreen();
    if (onChangeTableStatus == FunctionStatus.success) {
      selectedTable.value = null;
      selectedTableModel.value == null;
      showSnackBar(
        text: 'tableStatusChangeSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void onSetAvailableTap() async {
    showLoadingScreen();
    final onChangeTableStatus = await changeTableStatus(
        tableStatus: TableStatus.available,
        tableId: selectedTableModel.value!.tableId);
    hideLoadingScreen();
    if (onChangeTableStatus == FunctionStatus.success) {
      selectedTable.value = null;
      selectedTableModel.value == null;
      showSnackBar(
        text: 'tableStatusChangeSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> changeTableStatus(
      {required TableStatus tableStatus, required String tableId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('tables')
          .doc(tableId)
          .update({'status': tableStatus.name});
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
    tablesListener.cancel();
    tablesRefreshController.dispose();
    super.onClose();
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
}
