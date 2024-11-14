import 'dart:async';

import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/general_functions.dart';
import '../components/models.dart';

class TablesPageController extends GetxController {
  static TablesPageController get instance => Get.find();
  final RxList<TableModel> tablesData = <TableModel>[].obs;
  final RxList<int> selectedTables = <int>[].obs;
  final loadingTables = true.obs;
  late final StreamSubscription selectedTablesListener;
  bool navBarAccess = true;

  @override
  void onInit() async {
    //
    super.onInit();
  }

  @override
  void onReady() {
    tablesData.value = [
      TableModel(
          number: 1, status: TableStatus.available, currentOrderId: null),
      TableModel(
          number: 2, status: TableStatus.available, currentOrderId: null),
      TableModel(
          number: 3, status: TableStatus.available, currentOrderId: null),
      TableModel(
          number: 4,
          status: TableStatus.occupied,
          currentOrderId: 'order_8778'),
      TableModel(
          number: 5,
          status: TableStatus.occupied,
          currentOrderId: 'order_8006'),
      TableModel(
          number: 6, status: TableStatus.available, currentOrderId: null),
      TableModel(
          number: 7,
          status: TableStatus.occupied,
          currentOrderId: 'order_9162'),
      TableModel(
          number: 8, status: TableStatus.billed, currentOrderId: 'order_9169'),
      TableModel(
          number: 9,
          status: TableStatus.occupied,
          currentOrderId: 'order_5504'),
      TableModel(
          number: 10, status: TableStatus.unavailable, currentOrderId: null),
    ];
    Timer(const Duration(seconds: 1), () {
      loadingTables.value = false;
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

  void switchTables(int fromTableNo, int toTableNo) {
    final fromTable = tablesData[fromTableNo - 1];
    final toTable = tablesData[toTableNo - 1];
    final tempStatus = fromTable.status;
    final tempOrderId = fromTable.currentOrderId;
    tablesData[fromTableNo - 1] = TableModel(
      number: fromTable.number,
      status: toTable.status,
      currentOrderId: toTable.currentOrderId,
    );

    tablesData[toTableNo - 1] = TableModel(
      number: toTable.number,
      status: tempStatus,
      currentOrderId: tempOrderId,
    );
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
        text: 'tablesOrdersSwitched'.tr, snackBarType: SnackBarType.success);
  }

  bool acceptSwitchTable(int fromTableNo, int toTableNo) {
    if (fromTableNo == toTableNo) {
      return false;
    }
    final fromTable = tablesData[fromTableNo - 1];
    final toTable = tablesData[toTableNo - 1];
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

  void onTableSelected(int tableIndex) {
    final tableStatus = tablesData[tableIndex].status;
    if (selectedTables.contains(tableIndex + 1)) {
      selectedTables.remove(tableIndex + 1);
    } else if (tableStatus == TableStatus.available) {
      selectedTables.add(tableIndex + 1);
    } else if (tableStatus == TableStatus.occupied && selectedTables.isEmpty) {
      final currentOrderID = tablesData[tableIndex].currentOrderId;
      showSnackBar(
          text: 'Occupied order id $currentOrderID selected',
          snackBarType: SnackBarType.success);
    } else if (tableStatus == TableStatus.billed && selectedTables.isEmpty) {
      final currentOrderID = tablesData[tableIndex].currentOrderId;
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
}
