import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/orders/components/models.dart';
import '../../../cashier_side/orders/screens/order_details_screen_phone.dart';
import '../../../cashier_side/orders/screens/order_screen.dart';
import '../components/add_customer_widget.dart';
import '../components/add_customer_widget_phone.dart';
import '../screens/customer_orders_screen_phone.dart';

class AdminCustomersScreenController extends GetxController {
  static AdminCustomersScreenController get instance => Get.find();
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
        showSnackBar(
          text: 'cashierAccess'.tr,
          snackBarType: SnackBarType.success,
        );
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
    extended.value = false;
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

  void addCustomerPress() async {
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
        extended.value = false;
        key0.currentState?.collapse();
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
    } else if (validateNumbersOnly(number.value) != null) {
      showSnackBar(
        text: 'invalidPhoneNumber'.tr,
        snackBarType: SnackBarType.error,
      );
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
  }) {
    nameTextController.text = customerModel.name;
    percentageChosen.value = customerModel.discountType == 'percentage';
    discountTextController.text = customerModel.discountValue.toString();
    final initialNumber = customerModel.number;
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        AdminAddCustomerWidgetPhone(
          controller: this,
          edit: true,
          initialNumber: initialNumber,
          onPress: () => onEdit(
            customerId: customerModel.customerId,
            customerModel: customerModel,
            index: index,
          ),
        ),
      );
    } else {
      showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return AdminAddCustomerWidget(
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

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
