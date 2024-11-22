import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/controllers/tables_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../constants/enums.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';

class MainScreenController extends GetxController {
  static MainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final navBarIndex = 0.obs;
  final showNewOrderButton = true.obs;
  List<OrderModel> ordersList = <OrderModel>[];
  List<TableModel> tablesList = <TableModel>[];
  List<CustomerModel> customersList = <CustomerModel>[];

  @override
  void onInit() async {
    barController = SidebarXController(selectedIndex: 0, extended: false);
    pageController = PageController(initialPage: 0);
    homeScaffoldKey = GlobalKey<ScaffoldState>();
    tablesList = tablesDataExample;
    ordersList = ordersExample;
    customersList = customersExample;
    super.onInit();
  }

  @override
  void onReady() {
    barController.addListener(() {
      navBarIndex.value = barController.selectedIndex;
      pageController.jumpToPage(barController.selectedIndex);
      newOrderButtonVisibility();
    });
    super.onReady();
  }

  void newOrderButtonVisibility() {
    if (Get.isRegistered<TablesPageController>()) {
      final selectedTables = TablesPageController.instance.selectedTables;
      if (navBarIndex.value != 0 && showNewOrderButton.value == false) {
        showNewOrderButton.value = true;
      } else if (navBarIndex.value == 0 && selectedTables.isNotEmpty) {
        showNewOrderButton.value = false;
      }
    }
  }

  String getPageTitle(int navBarIndex) {
    switch (navBarIndex) {
      case 0:
        return 'tables'.tr;
      case 1:
        return 'ordersHistory'.tr;
      case 2:
        return 'reports'.tr;
      case 3:
        return 'account'.tr;
      case 4:
        return 'settings'.tr;
      default:
        return 'tablesView'.tr;
    }
  }

  @override
  void onClose() async {
    pageController.dispose();
    barController.dispose();
    super.onClose();
  }

  void onDrawerOpen() {
    barController.setExtended(true);
    homeScaffoldKey.currentState?.openDrawer();
  }

  onTakeawayOrderTap(bool isPhone) {
    final newOrder = OrderModel(
      orderId: Timestamp.now().seconds.toString(),
      tableNumbers: [],
      items: [],
      status: OrderStatus.active,
      timestamp: Timestamp.now(),
      totalAmount: 0.0,
      isTakeaway: true,
    );
    MainScreenController.instance.ordersList.add(newOrder);
    Get.to(
      () => isPhone
          ? OrderScreenPhone(
              orderModel: newOrder,
            )
          : OrderScreen(
              orderModel: newOrder,
            ),
      transition: Transition.noTransition,
    );
  }
}
