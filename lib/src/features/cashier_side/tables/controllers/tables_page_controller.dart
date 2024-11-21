import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/general_functions.dart';
import '../../orders/components/models.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';
import '../components/models.dart';

class TablesPageController extends GetxController {
  static TablesPageController get instance => Get.find();
  final RxList<TableModel> tablesList = <TableModel>[].obs;
  final List<TableModel> tablesInsert;
  final RxList<int> selectedTables = <int>[].obs;
  final loadingTables = true.obs;
  late final StreamSubscription selectedTablesListener;
  bool navBarAccess = true;
  TablesPageController({required this.tablesInsert});

  @override
  void onInit() async {
    //
    super.onInit();
  }

  @override
  void onReady() {
    Timer(const Duration(seconds: 1), () {
      loadingTables.value = false;
    });
    tablesList.value = tablesInsert;
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

  void switchTables(int fromTableNo, int toTableNo) {
    final fromTable = tablesList[fromTableNo - 1];
    final toTable = tablesList[toTableNo - 1];
    final fromTableStatus = fromTable.status;
    final fromTableOrderId = fromTable.currentOrderId;
    final toTableOrderId = toTable.currentOrderId;

    tablesList[fromTableNo - 1] = TableModel(
      tableId: fromTable.tableId,
      number: fromTable.number,
      status: toTable.status,
      currentOrderId: toTableOrderId,
    );

    tablesList[toTableNo - 1] = TableModel(
      tableId: toTable.tableId,
      number: toTable.number,
      status: fromTableStatus,
      currentOrderId: fromTableOrderId,
    );
    MainScreenController.instance.tablesList = tablesList;
    for (var order in MainScreenController.instance.ordersList) {
      if (order.tableNumbers != null) {
        if (order.tableNumbers!.contains(fromTableNo)) {
          order.tableNumbers!.remove(fromTableNo);
          order.tableNumbers!.add(toTableNo);
        } else if (order.tableNumbers!.contains(toTableNo)) {
          order.tableNumbers!.remove(toTableNo);
          order.tableNumbers!.add(fromTableNo);
        }
      }
    }

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

  void onTableSelected(int tableIndex, bool isPhone) {
    final tableStatus = tablesList[tableIndex].status;
    if (selectedTables.contains(tableIndex + 1)) {
      selectedTables.remove(tableIndex + 1);
    } else if (tableStatus == TableStatus.available) {
      selectedTables.add(tableIndex + 1);
    } else if (tableStatus == TableStatus.occupied && selectedTables.isEmpty) {
      final currentOrderID = tablesList[tableIndex].currentOrderId;
      final orderModel =
          MainScreenController.instance.ordersList.where((order) {
        return order.orderId == currentOrderID;
      }).first;
      Get.to(
        () => isPhone
            ? OrderScreenPhone(orderModel: orderModel)
            : OrderScreen(orderModel: orderModel),
        transition: Transition.noTransition,
      );
    } else if (tableStatus == TableStatus.billed && selectedTables.isEmpty) {
      final currentOrderID = tablesList[tableIndex].currentOrderId;
      showSnackBar(
          text: 'Billed order id $currentOrderID selected',
          snackBarType: SnackBarType.success);
    } else if (tableStatus == TableStatus.unavailable &&
        selectedTables.isEmpty) {
      return;
    } else {
      showSnackBar(
          text: 'tableUnavailable'.tr, snackBarType: SnackBarType.error);
    }
  }

  @override
  void onClose() async {
    selectedTablesListener.cancel();
    super.onClose();
  }

  void onBackPressed() {
    if (selectedTables.isNotEmpty) selectedTables.value = [];
    Get.back();
  }

  onNewOrder({required bool isPhone}) {
    final currentTimestamp = Timestamp.now();
    final newOrder = OrderModel(
      orderId: currentTimestamp.seconds.toString(),
      tableNumbers: selectedTables.value,
      items: [],
      status: OrderStatus.active,
      timestamp: currentTimestamp,
      totalAmount: 0.0,
      isTakeaway: false,
    );
    MainScreenController.instance.ordersList.add(newOrder);
    updateTableStatuses(selectedTables, tablesList, newOrder.orderId);
    selectedTables.value = [];
    MainScreenController.instance.tablesList = tablesList;

    navigateToOrderScreen(isPhone, newOrder);
  }

  void updateTableStatuses(List<int> selectedTableNumbers,
      List<TableModel> mainTablesList, String orderId) {
    for (int tableNo in selectedTableNumbers) {
      final tableIndex =
          mainTablesList.indexWhere((table) => table.number == tableNo);
      if (tableIndex != -1) {
        final table = mainTablesList[tableIndex];
        mainTablesList[tableIndex] = TableModel(
          tableId: table.tableId,
          number: table.number,
          status: TableStatus.occupied,
          currentOrderId: orderId,
        );
      }
    }
  }

  void navigateToOrderScreen(bool isPhone, OrderModel newOrder) {
    Get.to(
      () => isPhone
          ? OrderScreenPhone(orderModel: newOrder)
          : OrderScreen(orderModel: newOrder),
      transition: Transition.noTransition,
    );
  }
}
