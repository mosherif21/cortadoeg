import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../authentication/models.dart';
import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../components/models.dart';

class CustomerChooseController extends GetxController {
  final RxList<CustomerModel> customersList = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final RxBool extended = false.obs;
  final RxBool percentageChosen = true.obs;
  final RxBool loadingCustomers = true.obs;
  late final GlobalKey<ExpansionTileCoreState> key0;
  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameTextController;
  late final TextEditingController discountTextController;
  final RxString number = ''.obs;
  final customersRefreshController = RefreshController(initialRefresh: false);
  @override
  void onInit() async {
    nameTextController = TextEditingController();
    discountTextController = TextEditingController();
    key0 = GlobalKey<ExpansionTileCoreState>();
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
    loadCustomers();
    customersRefreshController.refreshToIdle();
    customersRefreshController.resetNoData();
  }

  void addCustomerPress() async {
    final manageCustomersPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.manageCustomers);
    if (manageCustomersPermission) {
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
        final newCustomer =
            await addCustomerDatabase(customerModel: customerModel);
        if (newCustomer != null) {
          customersList.add(newCustomer);
          Get.back(result: newCustomer);
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
