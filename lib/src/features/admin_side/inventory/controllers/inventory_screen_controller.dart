import 'dart:async';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/general_functions.dart';
import '../components/models.dart';
import '../components/product_details.dart';
import '../components/product_details_phone.dart';

class InventoryScreenController extends GetxController {
  static InventoryScreenController get instance => Get.find();
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final int pageSize = 10;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  Timer? _searchDebounce;
  String searchText = '';
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController costQuantityController = TextEditingController();
  final TextEditingController availableQuantityController =
      TextEditingController();
  final selectedMeasuringUnit = MeasuringUnit.gm.obs;
  final RxString selectedProductIconName = 'coffee'.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final refreshController = RefreshController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void initializeItem(ProductModel product) {
    productNameController.text = product.name;
    costController.text = product.cost.toStringAsFixed(2);
    costQuantityController.text = product.costQuantity.toString();
    availableQuantityController.text = product.availableQuantity.toString();
    selectedMeasuringUnit.value = product.measuringUnit;
    selectedProductIconName.value = product.iconName;
  }

  ProductModel getUpdatedProduct(String productId) {
    return ProductModel(
      id: productId,
      name: productNameController.text.trim(),
      measuringUnit: selectedMeasuringUnit.value,
      cost: double.tryParse(costController.text) ?? 0,
      costQuantity: int.tryParse(costQuantityController.text) ?? 0,
      availableQuantity: int.tryParse(availableQuantityController.text) ?? 0,
      iconName: selectedProductIconName.value,
    );
  }

  void clearProductSelectValues() {
    productNameController.text = '';
    costController.text = '';
    costQuantityController.text = '';
    availableQuantityController.text = '';
    selectedMeasuringUnit.value = MeasuringUnit.gm;
    selectedProductIconName.value = 'coffee';
  }

  void onProductSearch(String value) {
    if (value.trim().isEmpty) {
      if (searchText.isNotEmpty) {
        searchText = '';
        if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
        fetchProducts(reset: true);
      }
    } else {
      searchText = value;
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        fetchProducts(reset: true);
      });
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || (!reset && !hasMore)) return;

    if (reset) {
      products.clear();
      isLoading.value = true;
      lastDocument = null;
      hasMore = true;
    }
    try {
      Query query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('name_lowercase')
          .limit(pageSize);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }
      if (searchText.isNotEmpty) {
        query = query
            .where('name_lowercase', isGreaterThanOrEqualTo: searchText)
            .where('name_lowercase', isLessThan: '$searchText\uf8ff');
      }
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final fetchedItems = snapshot.docs.map((doc) {
          return ProductModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        products.addAll(fetchedItems);
        lastDocument = snapshot.docs.last;
        if (fetchedItems.length < pageSize) {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProductTap({required bool isPhone}) async {
    final newProduct = ProductModel(
      id: '',
      name: '',
      measuringUnit: MeasuringUnit.gm,
      cost: 0,
      costQuantity: 0,
      availableQuantity: 0,
      iconName: 'coffee',
    );
    initializeItem(newProduct);
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.63,
        maxHeight: 1,
        anchors: [0, 0.63, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return ManageProductDetailsPhone(
            controller: this,
            edit: false,
            productIndex: 0,
            scrollController: scrollController,
          );
        },
      );
      clearProductSelectValues();
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return ManageProductDetails(
            controller: this,
            edit: false,
            productIndex: 0,
          );
        },
      );
      clearProductSelectValues();
    }
  }

  Future<void> addItem() async {
    if (formKey.currentState!.validate()) {
      showLoadingScreen();
      final newProduct = getUpdatedProduct('');
      final addedProductId = await addProductDatabase(newProduct);
      hideLoadingScreen();
      if (addedProductId != null) {
        Get.back();
        newProduct.id = addedProductId;
        products.add(newProduct);
        showSnackBar(
          text: 'productAddedSuccess'.tr,
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

  Future<String?> addProductDatabase(ProductModel product) async {
    final productsCollectionRef =
        FirebaseFirestore.instance.collection('products');
    try {
      final doc = await productsCollectionRef.add(product.toFirestore());
      return doc.id;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return null;
  }

  void onProductTap({required bool isPhone, required int index}) async {
    final product = products[index];
    productNameController.text = product.name;
    costController.text = product.cost.toString();
    costQuantityController.text = product.costQuantity.toString();
    availableQuantityController.text = product.availableQuantity.toString();
    selectedMeasuringUnit.value = product.measuringUnit;
    selectedProductIconName.value = product.iconName;
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.63,
        maxHeight: 1,
        anchors: [0, 0.63, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return ManageProductDetailsPhone(
            controller: this,
            edit: true,
            productIndex: index,
            scrollController: scrollController,
          );
        },
      );
      clearProductSelectValues();
    } else {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return ManageProductDetails(
            controller: this,
            edit: true,
            productIndex: index,
          );
        },
      );
      clearProductSelectValues();
    }
  }

  void onSaveTap({required int index}) async {
    final product = products[index];
    final newProduct = getUpdatedProduct(product.id);
    if (product.name == newProduct.name &&
        product.cost == newProduct.cost &&
        product.costQuantity == newProduct.costQuantity &&
        product.measuringUnit == newProduct.measuringUnit &&
        product.availableQuantity == newProduct.availableQuantity &&
        product.iconName == selectedProductIconName.value) {
      Get.back();
    } else {
      if (formKey.currentState!.validate()) {
        showLoadingScreen();
        final saveStatus = await updateProductDatabase(newProduct);
        hideLoadingScreen();
        if (saveStatus == FunctionStatus.success) {
          Get.back();
          showSnackBar(
              text: 'categoryUpdateSuccess'.tr,
              snackBarType: SnackBarType.success);
          final index =
              products.indexWhere((product) => product.id == newProduct.id);
          if (index != -1) {
            products[index] = newProduct;
          }
          clearProductSelectValues();
        } else {
          showSnackBar(
              text: 'categoryUpdateFailed'.tr,
              snackBarType: SnackBarType.error);
        }
      }
    }
  }

  Future<FunctionStatus> updateProductDatabase(
      ProductModel updatedProduct) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('products')
          .doc(updatedProduct.id);
      await docRef.update(updatedProduct.toFirestore());
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return FunctionStatus.failure;
  }

  void onDeleteTap({required int index}) => displayAlertDialog(
        title: 'deleteProduct'.tr,
        body: 'deleteProductConfirm'.tr,
        positiveButtonText: 'yes'.tr,
        negativeButtonText: 'no'.tr,
        positiveButtonOnPressed: () async {
          final productId = products[index].id;
          showLoadingScreen();
          final functionStatus = await deleteProductDatabase(productId);
          hideLoadingScreen();
          if (functionStatus == FunctionStatus.success) {
            Get.close(2);
            products.removeWhere((product) => product.id == productId);
            showSnackBar(
              text: 'productDeleteSuccess'.tr,
              snackBarType: SnackBarType.success,
            );
            clearProductSelectValues();
          } else {
            showSnackBar(
              text: 'productDeleteFailed'.tr,
              snackBarType: SnackBarType.error,
            );
          }
        },
        negativeButtonOnPressed: () => Get.back(),
        mainIcon: Icons.delete_outline_rounded,
        color: CustomSheetColor(
            main: Colors.black, accent: Colors.black, icon: Colors.white),
      );

  Future<FunctionStatus> deleteProductDatabase(String productId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final productDocRef = firestore.collection('products').doc(productId);
      batch.delete(productDocRef);
      final itemsSnapshot = await firestore.collection('items').get();
      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final sizes = (itemData['sizes'] as List<dynamic>).map((size) {
          final sizeMap = size as Map<String, dynamic>;
          final recipe =
              (sizeMap['recipe'] as List<dynamic>).cast<Map<String, dynamic>>();
          final updatedRecipe =
              recipe.where((r) => r['productId'] != productId).toList();
          final updatedCostPrice = updatedRecipe.fold<double>(
            0.0,
            (total, r) =>
                total +
                (r['cost'] as double) *
                    (r['quantity'] as int) /
                    (r['costQuantity'] as int),
          );
          sizeMap['recipe'] = updatedRecipe;
          sizeMap['costPrice'] = updatedCostPrice;
          return sizeMap;
        }).toList();
        batch.update(itemDoc.reference, {'sizes': sizes});
      }
      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final options = itemData['options'] as Map<String, dynamic>? ?? {};
        final updatedOptions = options.map((key, value) {
          final optionList = value as List<dynamic>;
          final updatedOptionList = optionList.map((option) {
            final optionMap = option as Map<String, dynamic>;
            final recipe = (optionMap['recipe'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
            optionMap['recipe'] =
                recipe.where((r) => r['productId'] != productId).toList();
            return optionMap;
          }).toList();

          return MapEntry(key, updatedOptionList);
        });
        batch.update(itemDoc.reference, {'options': updatedOptions});
      }
      await batch.commit();

      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }

    return FunctionStatus.failure;
  }

  Future<void> onRefresh() async {
    fetchProducts(reset: true);
    refreshController.refreshCompleted();
  }

  void onLoadMore() async {
    fetchProducts();
    refreshController.loadComplete();
  }

  @override
  void onClose() {
    costController.dispose();
    costQuantityController.dispose();
    productNameController.dispose();
    availableQuantityController.dispose();
    refreshController.dispose();
    super.onClose();
  }
}
