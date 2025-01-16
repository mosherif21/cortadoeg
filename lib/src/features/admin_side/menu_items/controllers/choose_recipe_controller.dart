import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/admin_side/inventory/components/models.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';

class ChooseRecipeController extends GetxController {
  final RxList<ProductModel> productsList = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProductsList = <ProductModel>[].obs;
  final RxBool loadingProducts = true.obs;
  final productsRefreshController = RefreshController(initialRefresh: false);

  @override
  void onReady() {
    loadProducts();
    super.onReady();
  }

  void loadProducts() async {
    final products = await fetchProducts();
    if (products != null) {
      loadingProducts.value = false;
      products
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      productsList.value = products;
      filteredProductsList.value = productsList;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<List<ProductModel>?> fetchProducts() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('products').get();
      return querySnapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc.data(), doc.id);
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
    if (!loadingProducts.value) {
      filteredProductsList.value = searchText.trim().isEmpty
          ? productsList
          : productsList
              .where((customer) => customer.name
                  .toUpperCase()
                  .contains(searchText.toUpperCase().trimLeft()))
              .toList();
    }
  }

  void onRefresh() {
    loadingProducts.value = true;
    loadProducts();
    productsRefreshController.refreshToIdle();
    productsRefreshController.resetNoData();
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }

  void onProductTap({required int index}) =>
      Get.back(result: filteredProductsList[index]);
}
