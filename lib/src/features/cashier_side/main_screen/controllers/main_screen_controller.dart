import 'dart:async';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/features/cashier_side/customers/controllers/customers_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/components/close_day_shift_widget.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/features/cashier_side/tables/controllers/tables_page_controller.dart';
import 'package:cortadoeg/src/general/common_widgets/regular_bottom_sheet.dart';
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
import '../components/close_day_shift_widget_phone.dart';
import '../components/open_day_shift_widget.dart';
import '../components/open_day_shift_widget_phone.dart';
import '../components/transaction_widget.dart';
import '../components/transaction_widget_phone.dart';

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
  String reopenOrdersPasscodeHash = '';
  final RxBool navBarExtended = false.obs;
  final RxInt currentSelectedTransaction = 0.obs;
  late final StreamController<bool> verificationNotifier;
  final firestore = FirebaseFirestore.instance;
  final Rxn<String?> currentActiveShiftId = Rxn<String>(null);
  final TextEditingController openingAmountTextController =
      TextEditingController();
  final TextEditingController closingAmountTextController =
      TextEditingController();
  final TextEditingController drawerTransactionTextController =
      TextEditingController();
  final TextEditingController drawerTransactionDescTextController =
      TextEditingController();
  late final StreamSubscription activeShiftListener;
  final notificationsCount = 0.obs;
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      notificationCountStreamSubscription;

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
    activeShiftListener = listenToActiveShiftId().listen((activeShiftId) {
      if (activeShiftId != null) {
        currentActiveShiftId.value = activeShiftId;
      } else {
        currentActiveShiftId.value = null;
      }
    });
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
        reopenOrdersPasscodeHash = hashSnapshot['reopenOrdersHash']!.toString();
      }
    });
    handleNotificationsPermission();
    listenForNotificationCount();
    super.onReady();
  }

  void listenForNotificationCount() {
    try {
      final userId = AuthenticationRepository.instance.employeeInfo!.id;
      notificationCountStreamSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          notificationsCount.value = snapshot.data()!['unseenCount'] as int;
        } else {
          notificationsCount.value = 0;
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

  void onTransactionTypeChanged(index) {
    if (index != currentSelectedTransaction.value) {
      currentSelectedTransaction.value = index;
    }
  }

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
      case PasscodeType.reopenOrders:
        return reopenOrdersPasscodeHash;
    }
  }

  Stream<DocumentSnapshot?> getPasscodesHashStream() {
    return firestore
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
    // Default to showing the button
    showNewOrderButton.value = true;

    if (Get.isRegistered<TablesPageController>()) {
      final selectedTables = TablesPageController.instance.selectedTables;
      if (navBarIndex.value == 0 && selectedTables.isNotEmpty) {
        showNewOrderButton.value = false;
        return;
      }
    }

    if (Get.isRegistered<OrdersController>()) {
      final currentChosenOrder =
          OrdersController.instance.currentChosenOrder.value;
      if (navBarIndex.value == 1 && currentChosenOrder != null) {
        showNewOrderButton.value = false;
        return;
      }
    }

    if (Get.isRegistered<CustomersScreenController>()) {
      final currentChosenOrder =
          CustomersScreenController.instance.currentChosenOrder.value;
      if (navBarIndex.value == 2 && currentChosenOrder != null) {
        showNewOrderButton.value = false;
        return;
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
    activeShiftListener.cancel();
    notificationCountStreamSubscription?.cancel();
    openingAmountTextController.dispose();
    closingAmountTextController.dispose();
    drawerTransactionTextController.dispose();
    drawerTransactionDescTextController.dispose();

    super.onClose();
  }

  void onDrawerOpen() {
    barController.setExtended(true);
    homeScaffoldKey.currentState?.openDrawer();
  }

  onOpenDrawerTap(BuildContext context, bool isPhone) async {
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
        if (currentActiveShiftId.value != null) {
          if (isPhone) {
            RegularBottomSheet.showRegularBottomSheet(
              TransactionWidgetPhone(controller: this),
            );
          } else {
            showDialog(
              context: Get.context!,
              builder: (BuildContext context) {
                return TransactionWidget(controller: this);
              },
            );
          }
        } else {
          showSnackBar(
            text: 'drawerNoShiftOpened'.tr,
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

  TransactionType mapIndexToTransactionType(int value) {
    return value == 0
        ? TransactionType.payIn
        : value == 1
            ? TransactionType.payOut
            : TransactionType.cashDrop;
  }

  void openDrawerTransaction(
      {required double amount,
      required int transactionTypeIndex,
      required String description}) async {
    showLoadingScreen();
    final openDrawerStatus = await openDrawerDatabase(
        transactionTypeIndex: transactionTypeIndex,
        amount: amount,
        description: description);
    hideLoadingScreen();
    if (openDrawerStatus == FunctionStatus.success) {
      Get.back();
      openDrawerPrinter();
      showSnackBar(
        text: 'openingDrawer'.tr,
        snackBarType: SnackBarType.info,
      );
      drawerTransactionTextController.clear();
      drawerTransactionDescTextController.clear();
      currentSelectedTransaction.value = 0;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> openDrawerDatabase(
      {required double amount,
      required int transactionTypeIndex,
      required String description}) async {
    try {
      final transactionType = mapIndexToTransactionType(transactionTypeIndex);
      final batch = MainScreenController.instance.getLogCustodyTransactionBatch(
          shiftId: currentActiveShiftId.value!,
          type: transactionType,
          amount: amount,
          description: description);
      await batch.commit();
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

  onTakeawayOrderTap(bool isPhone) async {
    if (currentActiveShiftId.value != null) {
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
    } else {
      showSnackBar(
        text: 'errorNoShiftOpened'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  openDayShiftTap({required bool isPhone}) {
    final hasManageDayShiftsPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageDayShifts);
    if (hasManageDayShiftsPermission) {
      openDrawerPrinter();
      if (isPhone) {
        RegularBottomSheet.showRegularBottomSheet(
          OpenDayShiftWidgetPhone(
            openShiftPressed: (openingAmount) => openDayShift(openingAmount),
            openingAmountTextController: openingAmountTextController,
          ),
        );
      } else {
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return OpenDayShiftWidget(
              openShiftPressed: (openingAmount) => openDayShift(openingAmount),
              openingAmountTextController: openingAmountTextController,
            );
          },
        );
      }
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void openDayShift(double openingAmount) async {
    showLoadingScreen();
    final openShiftStatus = await openDayShiftDatabase(openingAmount);
    hideLoadingScreen();
    if (openShiftStatus == FunctionStatus.success) {
      Get.back();
      openingAmountTextController.clear();
      showSnackBar(
        text: 'dayShiftOpenedSuccessfully'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'dayShiftOpenFailed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  closeDayShiftTap({required bool isPhone}) async {
    final hasManageDayShiftsPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageDayShifts);
    if (hasManageDayShiftsPermission) {
      showLoadingScreen();
      final shiftHasActiveOrders =
          await getShiftActiveOrders(currentActiveShiftId.value!);
      hideLoadingScreen();
      if (shiftHasActiveOrders) {
        showSnackBar(
          text: 'shiftHasActiveOrders'.tr,
          snackBarType: SnackBarType.error,
        );
      } else {
        openDrawerPrinter();
        if (isPhone) {
          RegularBottomSheet.showRegularBottomSheet(
            CloseDayShiftWidgetPhone(
                closeShiftPressed: (closingAmount) =>
                    closeDayShift(closingAmount),
                closingAmountTextController: closingAmountTextController),
          );
        } else {
          showDialog(
            context: Get.context!,
            builder: (BuildContext context) {
              return CloseDayShiftWidget(
                  closeShiftPressed: (closingAmount) =>
                      closeDayShift(closingAmount),
                  closingAmountTextController: closingAmountTextController);
            },
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

  closeDayShift(double closingAmount) async {
    showLoadingScreen();
    final closeShiftModel =
        await closeDayShiftDatabase(currentActiveShiftId.value!, closingAmount);
    hideLoadingScreen();
    if (closeShiftModel != null) {
      Get.back();
      closingAmountTextController.clear();
      showSnackBar(
        text: 'dayShiftClosedSuccessfully'.tr,
        snackBarType: SnackBarType.success,
      );
      printCustodyReceipt(custody: closeShiftModel);
    } else {
      showSnackBar(
        text: 'dayShiftClosingFailed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<bool> getShiftActiveOrders(String shiftId) async {
    final ordersRef = FirebaseFirestore.instance.collection('orders');
    final orders = await ordersRef
        .where('shiftId', isEqualTo: shiftId)
        .where('status', isEqualTo: 'active')
        .get();
    if (orders.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<FunctionStatus> openDayShiftDatabase(double openingAmount) async {
    try {
      final custodyRef = firestore.collection('custody_shifts');
      final custodyReport = CustodyReport(
        id: '',
        openingTime: Timestamp.now(),
        closingTime: Timestamp.now(),
        openingAmount: openingAmount,
        cashPaymentsNet: 0.0,
        totalPayIns: 0.0,
        totalPayOuts: 0.0,
        cashDrop: 0.0,
        closingAmount: 0.0,
        expectedDrawerMoney: 0.0,
        difference: 0.0,
        drawerOpenCount: 0,
        isActive: true,
      );
      await custodyRef.add(custodyReport.toFirestore());
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

  Future<CustodyReport?> closeDayShiftDatabase(
      String activeShiftId, double closingDrawerAmount) async {
    try {
      final custodyDocRef =
          firestore.collection('custody_shifts').doc(activeShiftId);
      final custodySnapshot = await custodyDocRef.get();
      if (custodySnapshot.exists) {
        final custodyData = custodySnapshot.data()!;
        final expectedAmount = custodyData['opening_amount'] +
            custodyData['cash_payments_net'] +
            custodyData['total_pay_ins'] -
            custodyData['total_pay_outs'] -
            custodyData['cash_drop'];
        final difference = closingDrawerAmount - expectedAmount;
        await custodyDocRef.update({
          'isActive': false,
          'closingTime': FieldValue.serverTimestamp(),
          'closing_amount': closingDrawerAmount,
          'expected_drawer_money': expectedAmount,
          'difference': difference,
        });
        final custodyReportModel = CustodyReport.fromFirestore(custodySnapshot);
        custodyReportModel.closingAmount = closingDrawerAmount;
        custodyReportModel.difference = difference;
        custodyReportModel.expectedDrawerMoney = expectedAmount;
        return custodyReportModel;
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

  Stream<String?> listenToActiveShiftId() {
    final CollectionReference custodyReportsRef =
        FirebaseFirestore.instance.collection('custody_shifts');
    return custodyReportsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<CustodyReport> custodyReports = snapshot.docs.map((doc) {
          return CustodyReport.fromFirestore(doc);
        }).toList();
        return custodyReports.first.id;
      }
      return null;
    });
  }

  WriteBatch getLogCustodyTransactionBatch({
    required String shiftId,
    required TransactionType type,
    required double amount,
    String description = '',
  }) {
    final firestore = FirebaseFirestore.instance;
    final custodyReportRef =
        firestore.collection('custody_shifts').doc(shiftId);
    final transactionsRef = custodyReportRef.collection('transactions');
    final transaction = CustodyTransaction(
      id: '',
      type: type,
      amount: amount,
      description: description,
      timestamp: Timestamp.now(),
    );
    final batch = firestore.batch();
    batch.set(transactionsRef.doc(), transaction.toFirestore());
    final updates = <String, dynamic>{};

    switch (type) {
      case TransactionType.sale:
      case TransactionType.completeSale:
        updates['cash_payments_net'] = FieldValue.increment(amount);
        break;
      case TransactionType.reopenSale:
      case TransactionType.returnSale:
        updates['cash_payments_net'] = FieldValue.increment(-amount.abs());
        break;
      case TransactionType.payIn:
        updates['total_pay_ins'] = FieldValue.increment(amount);
        updates['drawer_open_count'] = FieldValue.increment(1);
        break;
      case TransactionType.payOut:
        updates['total_pay_outs'] = FieldValue.increment(amount);
        updates['drawer_open_count'] = FieldValue.increment(1);
        break;
      case TransactionType.cashDrop:
        updates['cash_drop'] = FieldValue.increment(amount);
        updates['drawer_open_count'] = FieldValue.increment(1);
        break;
    }
    batch.update(custodyReportRef, updates);
    return batch;
  }

  Future<OrderModel?> addTakeawayOrder() async {
    try {
      final orderNumber = await generateOrderNumber();
      if (orderNumber != null) {
        final orderDoc = firestore.collection('orders').doc();
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
          shiftId: currentActiveShiftId.value!,
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
      final ordersRef = firestore.collection('orders');
      final todayOrders = await ordersRef
          .where('shiftId', isEqualTo: currentActiveShiftId.value)
          .count()
          .get();

      final int orderCount = todayOrders.count ?? 1;
      return orderCount;
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
        UserPermission.manageTables);
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
