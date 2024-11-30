import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/customers/components/add_customer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../orders/components/models.dart';

class CustomersScreenController extends GetxController {
  final RxList<CustomerModel> customersList = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final RxBool extended = false.obs;
  final RxBool percentageChosen = true.obs;
  final RxBool loadingCustomers = true.obs;
  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameTextController;
  late final TextEditingController discountTextController;
  final RxString number = ''.obs;
  final customersRefreshController = RefreshController(initialRefresh: false);
  final RxList<OrderModel> customerOrders = <OrderModel>[].obs;
  final RxInt chosenCustomerIndex = 0.obs;
  @override
  void onInit() async {
    nameTextController = TextEditingController();
    discountTextController = TextEditingController();
    formKey = GlobalKey<FormState>();
    super.onInit();
  }

  @override
  void onReady() {
    loadCustomers();
    super.onReady();
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

  void onRefresh() {
    extended.value = false;
    loadingCustomers.value = true;
    chosenCustomerIndex.value = 0;
    loadCustomers();
    customersRefreshController.refreshToIdle();
    customersRefreshController.resetNoData();
  }

  void addCustomerPress() async {
    final discountText = discountTextController.text.trim();
    final name = nameTextController.text.trim();
    if (formKey.currentState!.validate() && isNumeric(discountText)) {
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
        Get.back();
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

  void onCustomerTap(
      {required int index, required CustomerModel customerModel}) async {
    chosenCustomerIndex.value = index;
  }

  void onEditPress(
      {required BuildContext context,
      required int index,
      required CustomerModel customerModel}) async {
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

  void onDeleteTap(
      {required int index, required CustomerModel customerModel}) async {
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
          onPress: () => addCustomerPress(),
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

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
