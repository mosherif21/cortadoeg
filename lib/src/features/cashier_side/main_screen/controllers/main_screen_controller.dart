import 'dart:async';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/controllers/tables_page_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';
import '../../tables/screens/tables_screen.dart';

class MainScreenController extends GetxController {
  static MainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final navBarIndex = 0.obs;
  final showNewOrderButton = true.obs;
  String editOrderPasscodeHash = '';
  String cancelOrderPasscodeHash = '';
  String manageDayShiftPasscodeHash = '';
  String openDrawerPasscodeHash = '';
  String finalizeOrdersPasscodeHash = '';
  String returnOrdersPasscodeHash = '';
  final RxBool navBarExtended = false.obs;
  late final StreamController<bool> verificationNotifier;
  @override
  void onInit() async {
    verificationNotifier = StreamController<bool>.broadcast();
    barController = SidebarXController(selectedIndex: 0, extended: false);
    pageController = PageController(initialPage: 0, keepPage: true);
    homeScaffoldKey = GlobalKey<ScaffoldState>();

    super.onInit();
  }

  @override
  void onReady() {
    final hasManageTablesPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageTables);
    if (!hasManageTablesPermission) {
      navBarIndex.value = 1;
      pageController.jumpToPage(navBarIndex.value);
      barController.selectIndex(1);
    }
    barController.addListener(() {
      navBarExtended.value = barController.extended;
      final selectedNavIndex = barController.selectedIndex;
      if (selectedNavIndex == 0) {
        final hasManageTablesPermission = hasPermission(
            AuthenticationRepository.instance.employeeInfo!,
            UserPermission.manageTables);
        if (hasManageTablesPermission) {
          navBarIndex.value = barController.selectedIndex;
          pageController.jumpToPage(barController.selectedIndex);
          newOrderButtonVisibility();
        } else {
          barController.selectIndex(navBarIndex.value);
          showSnackBar(
            text: 'functionNotAllowed'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      } else if (selectedNavIndex == 2) {
        final hasManageCustomersPermission = hasPermission(
            AuthenticationRepository.instance.employeeInfo!,
            UserPermission.manageCustomers);
        if (hasManageCustomersPermission) {
          navBarIndex.value = barController.selectedIndex;
          pageController.jumpToPage(barController.selectedIndex);
          newOrderButtonVisibility();
        } else {
          barController.selectIndex(navBarIndex.value);
          showSnackBar(
            text: 'functionNotAllowed'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      } else {
        navBarIndex.value = barController.selectedIndex;
        pageController.jumpToPage(barController.selectedIndex);
        newOrderButtonVisibility();
      }
    });
    getPasscodesHashStream().listen((hashSnapshot) {
      if (hashSnapshot != null) {
        editOrderPasscodeHash = hashSnapshot['editOrderItemsHash']!.toString();
        cancelOrderPasscodeHash = hashSnapshot['cancelOrdersHash']!.toString();
        manageDayShiftPasscodeHash =
            hashSnapshot['manageDayShiftHash']!.toString();
        openDrawerPasscodeHash = hashSnapshot['openDrawerHash']!.toString();
        finalizeOrdersPasscodeHash =
            hashSnapshot['finalizeOrdersHash']!.toString();
        returnOrdersPasscodeHash = hashSnapshot['returnOrdersHash']!.toString();
      }
    });
    handleNotificationsPermission();
    super.onReady();
  }

  // Future<FunctionStatus> saveEditOrderPasscode(String passcode) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('passcodes')
  //         .doc('passcodes')
  //         .set({
  //       'editOrderItemsHash': BCrypt.hashpw(
  //           isLangEnglish() ? passcode : translateArabicToEnglish(passcode),
  //           BCrypt.gensalt()),
  //     }, SetOptions(merge: true));
  //     return FunctionStatus.success;
  //   } on FirebaseException catch (error) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(error.toString());
  //     }
  //   } catch (err) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(err.toString());
  //     }
  //   }
  //   return FunctionStatus.failure;
  // }

  Future<bool> showPassCodeScreen(
      {required BuildContext context,
      required PasscodeType passcodeType}) async {
    bool valid = false;
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return PasscodeScreen(
          digits: isLangEnglish()
              ? ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
              : ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٠'],
          title: Text(
            'enterPasscode'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          passwordEnteredCallback: (String enteredPasscode) {
            bool isValid = verifyPasscode(enteredPasscode, passcodeType);
            verificationNotifier.add(isValid);
          },
          cancelButton: Text(
            'cancel'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          isValidCallback: () => valid = true,
          cancelCallback: () => Get.back(),
          deleteButton: Text(
            'delete'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          shouldTriggerVerification: verificationNotifier.stream,
        );
      },
    );
    return valid;
  }

  bool verifyPasscode(String inputPasscode, PasscodeType passcodeType) {
    return BCrypt.checkpw(
        isLangEnglish()
            ? inputPasscode
            : translateArabicToEnglish(inputPasscode),
        getPasscodeTypeHash(passcodeType));
  }

  String getPasscodeTypeHash(PasscodeType type) {
    switch (type) {
      case PasscodeType.editOrderItems:
        return editOrderPasscodeHash;
      case PasscodeType.cancelOrders:
        return cancelOrderPasscodeHash;
      case PasscodeType.manageDayShift:
        return manageDayShiftPasscodeHash;
      case PasscodeType.openDrawer:
        return openDrawerPasscodeHash;
      case PasscodeType.finalizeOrders:
        return finalizeOrdersPasscodeHash;
      case PasscodeType.returnOrders:
        return returnOrdersPasscodeHash;
    }
  }

  Stream<DocumentSnapshot?> getPasscodesHashStream() {
    return FirebaseFirestore.instance
        .collection('passcodes')
        .doc('passcodes')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot;
      }
      return null;
    }).handleError((error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    });
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
    if (Get.isRegistered<OrdersController>()) {
      final currentChosenOrder =
          OrdersController.instance.currentChosenOrder.value;
      if (currentChosenOrder != null) {
        showNewOrderButton.value = false;
      } else {
        showNewOrderButton.value = true;
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
      case 3:
        return 'account'.tr;
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

  onOpenDrawerTap(BuildContext context) async {
    final hasOpenDrawerPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.openDrawer);
    final hasOpenDrawerPassPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.openDrawerWithPass);
    if (hasOpenDrawerPermission || hasOpenDrawerPassPermission) {
      final passcodeValid = hasOpenDrawerPermission
          ? true
          : await MainScreenController.instance.showPassCodeScreen(
              context: context, passcodeType: PasscodeType.openDrawer);
      if (passcodeValid) {
        showSnackBar(
          text: 'openingDrawer'.tr,
          snackBarType: SnackBarType.info,
        );
        // showLoadingScreen();
        final openStatus = await openDrawerTap();
        // hideLoadingScreen();
        if (openStatus == FunctionStatus.success) {
          showSnackBar(
            text: 'drawerOpenedSuccessfully'.tr,
            snackBarType: SnackBarType.success,
          );
        } else {
          showSnackBar(
            text: 'drawerOpenedFailed'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      }
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
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
      final orderNumber = await generateOrderNumber();
      if (orderNumber != null) {
        final orderDoc = FirebaseFirestore.instance.collection('orders').doc();
        final employeeInfo = AuthenticationRepository.instance.employeeInfo!;
        final takeawayOrder = OrderModel(
          orderNumber: orderNumber,
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
          employeeId: employeeInfo.id,
          employeeName: employeeInfo.name,
        );
        await orderDoc.set(takeawayOrder.toFirestore());
        if (AuthenticationRepository.instance.userRole == Role.takeaway) {
          sendNotification(
              employeeId: 'empty',
              notificationType: NotificationType.newTakeawayOrder,
              orderNumber: 'empty');
        }
        return takeawayOrder;
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

  void dineInOrderTap({required BuildContext context}) {
    final hasManageTablesPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageOrders);
    if (hasManageTablesPermission) {
      Get.to(
        () => const TablesScreen(navBarAccess: false),
        transition: Transition.noTransition,
      );
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }
}
