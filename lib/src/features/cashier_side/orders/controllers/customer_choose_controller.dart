import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../components/models.dart';

class CustomerChooseController extends GetxController {
  CustomerChooseController({required this.customers});
  final List<CustomerModel> customers;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final RxBool extended = false.obs;
  final RxBool percentageChosen = true.obs;
  late final GlobalKey<ExpansionTileCoreState> key0;
  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameTextController;
  late final TextEditingController discountTextController;
  final RxString number = ''.obs;
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
    customers
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    filteredCustomers.value = customers;
    super.onReady();
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
