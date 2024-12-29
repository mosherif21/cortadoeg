import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/customers/components/add_customer_widget.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../authentication/models.dart';
import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/models.dart';
import '../../main_screen/controllers/main_screen_controller.dart';
import '../../orders/components/models.dart';
import '../../orders/screens/order_details_screen_phone.dart';
import '../../orders/screens/order_screen.dart';
import '../../orders/screens/order_screen_phone.dart';
import '../../tables/components/models.dart';
import '../screens/customer_orders_screen_phone.dart';

class CustomersScreenController extends GetxController {
  final RxList<CustomerModel> customersList = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final RxBool percentageChosen = true.obs;
  final RxBool loadingCustomers = true.obs;
  final RxBool loadingCustomerOrders = true.obs;
  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameTextController;
  late final TextEditingController discountTextController;
  final RxString number = ''.obs;
  final customersRefreshController = RefreshController(initialRefresh: false);
  final customerOrdersRefreshController =
      RefreshController(initialRefresh: false);
  final RxList<OrderModel> customerOrders = <OrderModel>[].obs;
  final RxInt chosenCustomerIndex = 0.obs;
  final Rxn<OrderModel?> currentChosenOrder = Rxn<OrderModel>(null);
  late final GlobalKey<ExpansionTileCoreState> key0;
  final RxBool extended = false.obs;
  @override
  void onInit() async {
    nameTextController = TextEditingController();
    discountTextController = TextEditingController();
    formKey = GlobalKey<FormState>();
    key0 = GlobalKey<ExpansionTileCoreState>();
    super.onInit();
  }

  @override
  void onReady() {
    loadCustomers();
    super.onReady();
  }

  void onOrderTap({required int chosenIndex, required bool isPhone}) async {
    final chosenOrder = customerOrders[chosenIndex];
    if (isPhone) {
      bool changed = false;
      if (chosenOrder.status == OrderStatus.active) {
        final result = await Get.to(
          () => OrderScreenPhone(orderModel: chosenOrder),
          transition: getPageTransition(),
        );
        if (result != null) {
          changed = result;
        }
      } else {
        final result = await Get.to(
          () => OrderDetailsScreenPhone(
            orderModel: chosenOrder,
            controller: this,
          ),
          transition: getPageTransition(),
        );
        if (result != null) {
          changed = result;
        }
      }
      if (changed) {
        onCustomerOrdersRefresh();
      }
    } else {
      if (currentChosenOrder.value == chosenOrder) {
        currentChosenOrder.value = null;
        MainScreenController.instance.showNewOrderButton.value = true;
      } else {
        if (chosenOrder.status == OrderStatus.active) {
          final result = await Get.to(
            () => OrderScreen(orderModel: chosenOrder),
            transition: getPageTransition(),
          );
          if (result != null) {
            if (result) {
              onCustomerOrdersRefresh();
            }
          }
        } else {
          currentChosenOrder.value = chosenOrder;
          MainScreenController.instance.showNewOrderButton.value = false;
        }
      }
    }
  }

  void loadCustomers() async {
    final customers = await fetchCustomers();
    if (customers != null) {
      loadingCustomers.value = false;
      customers
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      customersList.value = customers;
      filteredCustomers.value = customersList;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<List<CustomerModel>?> fetchCustomers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('customers').get();
      return querySnapshot.docs.map((doc) {
        return CustomerModel.fromFirestore(doc.data(), doc.id);
      }).toList();
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

  void onCustomerSearch(String searchText) {
    if (!loadingCustomers.value) {
      filteredCustomers.value = searchText.trim().isEmpty
          ? customersList
          : customersList
              .where((customer) => customer.name
                  .toUpperCase()
                  .contains(searchText.toUpperCase().trimLeft()))
              .toList();
    }
  }

  void onCustomersRefresh() {
    loadingCustomers.value = true;
    chosenCustomerIndex.value = 0;
    loadCustomers();
    currentChosenOrder.value = null;
    customersRefreshController.refreshToIdle();
    customersRefreshController.resetNoData();
  }

  void onCustomerOrdersRefresh() async {
    final index = chosenCustomerIndex.value;
    final chosenCustomerId = customersList[index - 1].customerId;
    loadingCustomerOrders.value = true;
    currentChosenOrder.value = null;
    customerOrdersRefreshController.refreshToIdle();
    customerOrdersRefreshController.resetNoData();
    showLoadingScreen();
    final orders = await getOrdersByCustomerId(chosenCustomerId);
    hideLoadingScreen();
    if (orders != null) {
      chosenCustomerIndex.value = index;
      customerOrders.value = orders;
      loadingCustomerOrders.value = false;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void addCustomerPress({required bool isPhone}) async {
    final discountText = discountTextController.text.trim();
    final name = nameTextController.text.trim();

    if (formKey.currentState!.validate() &&
        isNumeric(discountText) &&
        validateNumbersOnly(number.value) == null) {
      final customerModel = CustomerModel(
        customerId: '',
        name: name,
        number: number.value,
        discountType: percentageChosen.value ? 'percentage' : 'value',
        discountValue: double.parse(discountText),
      );
      showLoadingScreen();
      final newCustomer =
          await addCustomerDatabase(customerModel: customerModel);
      hideLoadingScreen();
      if (newCustomer != null) {
        customersList.add(newCustomer);
        if (isPhone) {
          extended.value = false;
        } else {
          Get.back();
        }
        nameTextController.clear();
        discountTextController.clear();
        percentageChosen.value = true;
        showSnackBar(
          text: 'addCustomerSuccess'.tr,
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<List<OrderModel>?> getOrdersByCustomerId(String customerId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .get();
      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();

      return orders;
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

  void onCustomerTap(
      {required int index,
      required String customerId,
      required bool isPhone}) async {
    showLoadingScreen();
    final orders = await getOrdersByCustomerId(customerId);
    hideLoadingScreen();
    if (orders != null) {
      chosenCustomerIndex.value = index;
      customerOrders.value = orders;
      loadingCustomerOrders.value = false;
      if (isPhone) {
        await Get.to(
          () => CustomerOrdersScreenPhone(
            controller: this,
            customerId: customerId,
          ),
          transition: getPageTransition(),
        );
        chosenCustomerIndex.value = 0;
      }
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  void onEditPress({
    required BuildContext context,
    required int index,
    required CustomerModel customerModel,
    required bool isPhone,
  }) async {
    nameTextController.text = customerModel.name;
    percentageChosen.value = customerModel.discountType == 'percentage';
    discountTextController.text = customerModel.discountValue.toString();
    final initialNumber = customerModel.number;
    await showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return AddCustomerWidget(
          controller: this,
          edit: true,
          initialNumber: initialNumber,
          onPress: () => onEdit(
            customerId: customerModel.customerId,
            customerModel: customerModel,
            index: index,
          ),
        );
      },
    );
  }

  void onEdit(
      {required String customerId,
      required int index,
      required CustomerModel customerModel}) async {
    final discountText = discountTextController.text.trim();
    final name = nameTextController.text.trim();
    if (formKey.currentState!.validate() && isNumeric(discountText)) {
      final customer = CustomerModel(
        customerId: customerId,
        name: name,
        number: number.value,
        discountType: percentageChosen.value ? 'percentage' : 'value',
        discountValue: double.parse(discountText),
      );
      showLoadingScreen();
      final editStatus = await editCustomerDatabase(
          customerId: customerId, customerModel: customer);
      hideLoadingScreen();
      if (editStatus == FunctionStatus.success) {
        customersList[index] = customer;
        Get.back();
        nameTextController.clear();
        discountTextController.clear();
        percentageChosen.value = true;
        showSnackBar(
          text: 'editCustomerSuccess'.tr,
          snackBarType: SnackBarType.success,
        );
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> editCustomerDatabase(
      {required String customerId,
      required CustomerModel customerModel}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('customers')
          .doc(customerId)
          .update(customerModel.toFirestore());
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
    return FunctionStatus.failure;
  }

  void onDeleteTap({
    required int index,
    required CustomerModel customerModel,
    required bool isPhone,
  }) async {
    showLoadingScreen();
    final deleteStatus =
        await removeCustomerDatabase(customerId: customerModel.customerId);
    hideLoadingScreen();
    if (deleteStatus == FunctionStatus.success) {
      customersList.remove(customerModel);
      if (index == chosenCustomerIndex.value) {
        chosenCustomerIndex.value = 0;
        customerOrders.clear();
      } else if (index < chosenCustomerIndex.value) {
        chosenCustomerIndex.value -= 1;
      }
      showSnackBar(
        text: 'deleteCustomerSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> removeCustomerDatabase(
      {required String customerId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('customers').doc(customerId).delete();
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
    return FunctionStatus.failure;
  }

  Future<CustomerModel?> addCustomerDatabase(
      {required CustomerModel customerModel}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final newCustomerDoc = firestore.collection('customers').doc();
      customerModel.customerId = newCustomerDoc.id;
      await newCustomerDoc.set(customerModel.toFirestore());
      return customerModel;
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

  void onAddCustomerTap(BuildContext context) async {
    await showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return AddCustomerWidget(
          controller: this,
          edit: false,
          onPress: () => addCustomerPress(isPhone: false),
        );
      },
    );
  }

  bool isNumeric(String str) {
    if (str.isEmpty) {
      showSnackBar(
          text: 'enterDiscountValue'.tr, snackBarType: SnackBarType.error);
      return false;
    } else if (double.tryParse(str) == null) {
      showSnackBar(text: 'enterNumber'.tr, snackBarType: SnackBarType.error);
      return false;
    } else {
      return true;
    }
  }

  Future<bool?> checkIfShiftActive(String shiftId) async {
    try {
      final shiftDoc = await FirebaseFirestore.instance
          .collection('custody_shifts')
          .doc(shiftId)
          .get();
      if (shiftDoc.exists) {
        return shiftDoc['isActive'] as bool;
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return false;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
    return null;
  }

  void onReopenOrderTap(
      {required bool isPhone, OrderModel? aOrderModel}) async {
    final hasManageOrdersPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageOrders);
    if (hasManageOrdersPermission) {
      showLoadingScreen();
      final orderModel = isPhone ? aOrderModel! : currentChosenOrder.value!;
      final orderShiftIsActive = await checkIfShiftActive(orderModel.shiftId);
      if (orderShiftIsActive == null) {
        hideLoadingScreen();
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      } else if (!orderShiftIsActive) {
        hideLoadingScreen();
        showSnackBar(
          text: 'orderShiftInActive'.tr,
          snackBarType: SnackBarType.error,
        );
      } else {
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
            await reopenOrder(orderModel: orderModel, tablesList: tablesList);
        hideLoadingScreen();
        if (reopenOrderStatus == FunctionStatus.success) {
          currentChosenOrder.value = null;
          await Get.to(
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
          if (isPhone) {
            Get.back(result: true);
          } else {
            onCustomerOrdersRefresh();
          }
        } else {
          showSnackBar(
            text: 'errorOccurred'.tr,
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

  Future<FunctionStatus> reopenOrder(
      {required OrderModel orderModel,
      required List<TableModel> tablesList}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = MainScreenController.instance.getLogCustodyTransactionBatch(
          type: TransactionType.reopenSale,
          amount: orderModel.totalAmount,
          shiftId: orderModel.shiftId);
      batch.update(firestore.collection('orders').doc(orderModel.orderId), {
        'status': OrderStatus.active.name,
      });
      for (var table in tablesList) {
        batch.update(firestore.collection('tables').doc(table.tableId), {
          'status': TableStatus.occupied.name,
          'currentOrderId': orderModel.orderId,
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

  void returnOrderTap(
      {required bool isPhone,
      OrderModel? orderModel,
      required BuildContext context}) async {
    final hasReturnOrdersPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.returnOrders);
    final hasReturnOrdersPassPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.returnOrdersWithPass);
    if (hasReturnOrdersPermission || hasReturnOrdersPassPermission) {
      final passcodeValid = hasReturnOrdersPermission
          ? true
          : await MainScreenController.instance.showPassCodeScreen(
              context: context, passcodeType: PasscodeType.returnOrders);
      if (passcodeValid) {
        showLoadingScreen();
        final order = isPhone ? orderModel! : currentChosenOrder.value!;
        final orderShiftIsActive = await checkIfShiftActive(order.shiftId);
        if (orderShiftIsActive == null) {
          hideLoadingScreen();
          showSnackBar(
            text: 'errorOccurred'.tr,
            snackBarType: SnackBarType.error,
          );
        } else if (!orderShiftIsActive) {
          hideLoadingScreen();
          showSnackBar(
            text: 'orderShiftInActive'.tr,
            snackBarType: SnackBarType.error,
          );
        } else {
          final returnOrderStatus =
              await returnOrder(isPhone: isPhone, orderModel: order);
          hideLoadingScreen();
          if (returnOrderStatus == FunctionStatus.success) {
            if (isPhone) {
              Get.back(result: true);
            } else {
              currentChosenOrder.value = null;
              onCustomerOrdersRefresh();
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
      }
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> returnOrder(
      {required bool isPhone, required OrderModel orderModel}) async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderModel.orderId);
      final batch = MainScreenController.instance.getLogCustodyTransactionBatch(
          type: TransactionType.returnSale,
          amount: orderModel.totalAmount,
          shiftId: orderModel.shiftId);
      batch.update(orderReference, {'status': OrderStatus.returned.name});
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

  void completeOrderTap({required bool isPhone, OrderModel? orderModel}) async {
    final hasManageOrdersPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageOrders);
    if (hasManageOrdersPermission) {
      showLoadingScreen();
      final order = isPhone ? orderModel! : currentChosenOrder.value!;
      final orderShiftIsActive = await checkIfShiftActive(order.shiftId);
      if (orderShiftIsActive == null) {
        hideLoadingScreen();
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      } else if (!orderShiftIsActive) {
        hideLoadingScreen();
        showSnackBar(
          text: 'orderShiftInActive'.tr,
          snackBarType: SnackBarType.error,
        );
      } else {
        final completeOrderStatus =
            await completeOrder(isPhone: isPhone, orderModel: order);
        hideLoadingScreen();
        if (completeOrderStatus == FunctionStatus.success) {
          if (isPhone) {
            Get.back(result: true);
          } else {
            currentChosenOrder.value = null;
            onCustomerOrdersRefresh();
          }
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
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> completeOrder(
      {required bool isPhone, required OrderModel orderModel}) async {
    try {
      final orderReference = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderModel.orderId);
      final batch = MainScreenController.instance.getLogCustodyTransactionBatch(
          type: TransactionType.completeSale,
          amount: orderModel.totalAmount,
          shiftId: orderModel.shiftId);
      batch.update(orderReference, {'status': OrderStatus.complete.name});
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

  void printOrderTap(
      {required bool isPhone, required OrderModel orderModel}) async {
    showLoadingScreen();
    final printStatus =
        await chargeOrderPrinter(order: orderModel, openDrawer: false);
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

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
