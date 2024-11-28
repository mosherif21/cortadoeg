import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/controllers/tables_page_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';

class MainScreenController extends GetxController {
  static MainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final navBarIndex = 0.obs;
  final showNewOrderButton = true.obs;

  @override
  void onInit() async {
    barController = SidebarXController(selectedIndex: 0, extended: false);
    pageController = PageController(initialPage: 0);
    homeScaffoldKey = GlobalKey<ScaffoldState>();
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
        return 'customers'.tr;
      case 4:
        return 'reports'.tr;
      case 5:
        return 'account'.tr;
      case 6:
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

  onTakeawayOrderTap(bool isPhone) async {
    showLoadingScreen();
    final takeawayOrder = await addTakeawayOrder();
    hideLoadingScreen();
    if (takeawayOrder != null) {
      Get.to(
        () => isPhone
            ? OrderScreenPhone(
                orderModel: takeawayOrder,
              )
            : OrderScreen(
                orderModel: takeawayOrder,
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

  Future<OrderModel?> addTakeawayOrder() async {
    try {
      final orderDoc = FirebaseFirestore.instance.collection('orders').doc();
      final takeawayOrder = OrderModel(
        orderId: orderDoc.id,
        tableNumbers: [],
        items: [],
        status: OrderStatus.active,
        timestamp: Timestamp.now(),
        totalAmount: 0.0,
        discountAmount: 0.0,
        subtotalAmount: 0.0,
        taxTotalAmount: 0.0,
        isTakeaway: true,
      );
      await orderDoc.set(takeawayOrder.toFirestore());
      return takeawayOrder;
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
