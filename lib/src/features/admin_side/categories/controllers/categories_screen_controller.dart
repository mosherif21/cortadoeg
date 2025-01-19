import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/admin_side/categories/components/add_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/orders/components/models.dart';
import '../components/add_category_phone.dart';
import '../components/category_details.dart';
import '../components/category_details_phone.dart';

class CategoryScreenController extends GetxController {
  static CategoryScreenController get instance => Get.find();
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool loadingCategories = false.obs;
  final int pageSize = 10;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  Timer? _searchDebounce;
  String searchText = '';
  final RefreshController categoryRefreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController categoryNameTextController =
      TextEditingController();
  final RxString selectedCategoryIconName = ''.obs;
  late final GlobalKey<FormState> formKey;

  @override
  void onInit() {
    formKey = GlobalKey<FormState>();
    fetchCategories();
    super.onInit();
  }

  void onCategoriesSearch(String value) {
    if (value.trim().isEmpty) {
      if (searchText.isNotEmpty) {
        searchText = '';
        if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
        fetchCategories(reset: true);
      }
    } else {
      searchText = value;
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        fetchCategories(reset: true);
      });
    }
  }

  Future<void> fetchCategories({bool reset = false}) async {
    if (loadingCategories.value || (!reset && !hasMore)) return;

    if (reset) {
      categories.clear();
      loadingCategories.value = true;
      lastDocument = null;
      hasMore = true;
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('categories')
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
        final fetchedCategories = snapshot.docs.map((doc) {
          return CategoryModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        categories.addAll(fetchedCategories);
        lastDocument = snapshot.docs.last;

        if (fetchedCategories.length < pageSize) {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      showSnackBar(
        text: e.toString(),
        snackBarType: SnackBarType.error,
      );
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    } finally {
      loadingCategories.value = false;
    }
  }

  void onRefresh() async {
    fetchCategories(reset: true);
    categoryRefreshController.refreshCompleted();
  }

  void onLoadMore() async {
    fetchCategories();
    categoryRefreshController.loadComplete();
  }

  void clearCategorySelectValues() {
    selectedCategoryIconName.value = categoriesIconMap.keys.toList()[1];
    categoryNameTextController.clear();
  }

  void addCategoryTap({required bool isPhone}) {
    clearCategorySelectValues();
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        AddCategoryPhone(
          categoryNameTextController: categoryNameTextController,
          selectedCategoryIconName: selectedCategoryIconName,
          onAddTap: () => addCategory(),
          formKey: formKey,
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AddCategory(
            categoryNameTextController: categoryNameTextController,
            selectedCategoryIconName: selectedCategoryIconName,
            onAddTap: () => addCategory(),
            formKey: formKey,
          );
        },
      );
    }
  }

  void addCategory() async {
    if (formKey.currentState!.validate()) {
      final categoryName = categoryNameTextController.text.trim();
      showLoadingScreen();
      final functionStatus = await addCategoryDatabase(
          iconName: selectedCategoryIconName.value, categoryName: categoryName);
      hideLoadingScreen();
      if (functionStatus == FunctionStatus.success) {
        Get.back();
        showSnackBar(
          text: 'categoryAddedSuccess'.tr,
          snackBarType: SnackBarType.success,
        );
        onRefresh();
        clearCategorySelectValues();
      } else {
        showSnackBar(
          text: 'categoryAddedFailed'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> addCategoryDatabase(
      {required String iconName, required String categoryName}) async {
    final firestoreUsersCollRef =
        FirebaseFirestore.instance.collection('categories');
    try {
      await firestoreUsersCollRef.add({
        'iconName': iconName,
        'name': categoryName,
        'name_lowercase': categoryName.toLowerCase(),
      });
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

  void onDeleteTap({required String categoryId}) => displayAlertDialog(
        title: 'deleteCategory'.tr,
        body: 'deleteCategoryConfirm'.tr,
        positiveButtonText: 'yes'.tr,
        negativeButtonText: 'no'.tr,
        positiveButtonOnPressed: () async {
          showLoadingScreen();
          final functionStatus = await deleteCategoryAndItems(categoryId);
          hideLoadingScreen();
          if (functionStatus == FunctionStatus.success) {
            Get.close(2);
            showSnackBar(
              text: 'categoryDeleteSuccess'.tr,
              snackBarType: SnackBarType.success,
            );
            onRefresh();
            clearCategorySelectValues();
          } else {
            showSnackBar(
              text: 'categoryDeleteFailed'.tr,
              snackBarType: SnackBarType.error,
            );
          }
        },
        negativeButtonOnPressed: () => Get.back(),
        mainIcon: Icons.delete_outline_rounded,
        color: CustomSheetColor(
            main: Colors.black, accent: Colors.black, icon: Colors.white),
      );

  Future<FunctionStatus> deleteCategoryAndItems(String categoryId) async {
    final categoriesCollectionRef =
        FirebaseFirestore.instance.collection('categories');
    final itemsCollectionRef = FirebaseFirestore.instance.collection('items');
    final batch = FirebaseFirestore.instance.batch();

    try {
      batch.delete(categoriesCollectionRef.doc(categoryId));
      final itemsSnapshot = await itemsCollectionRef
          .where('categoryId', isEqualTo: categoryId)
          .get();
      for (var doc in itemsSnapshot.docs) {
        batch.delete(doc.reference);
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

  void onSaveTap({required int index}) async {
    final category = categories[index];
    final newCategoryName = categoryNameTextController.text.trim();
    final newCategoryIcon = selectedCategoryIconName.value.trim();
    if (category.name == newCategoryName &&
        category.iconName == newCategoryIcon) {
      Get.back();
    } else {
      if (formKey.currentState!.validate()) {
        showLoadingScreen();
        final saveStatus = await updateCategoryDatabase(
            categoryId: category.id,
            iconName: newCategoryIcon,
            categoryName: newCategoryName);
        hideLoadingScreen();
        if (saveStatus == FunctionStatus.success) {
          Get.back();
          showSnackBar(
              text: 'categoryUpdateSuccess'.tr,
              snackBarType: SnackBarType.success);
          onRefresh();
          clearCategorySelectValues();
        } else {
          showSnackBar(
              text: 'categoryUpdateFailed'.tr,
              snackBarType: SnackBarType.error);
        }
      }
    }
  }

  Future<FunctionStatus> updateCategoryDatabase(
      {required String categoryId,
      required String iconName,
      required String categoryName}) async {
    final firestoreUsersCollRef =
        FirebaseFirestore.instance.collection('categories');
    try {
      await firestoreUsersCollRef.doc(categoryId).update({
        'iconName': iconName,
        'name': categoryName,
        'name_lowercase': categoryName.toLowerCase(),
      });
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

  void onCategoryTap({required bool isPhone, required int index}) {
    final category = categories[index];
    categoryNameTextController.text = category.name;
    selectedCategoryIconName.value = category.iconName;
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        CategoryDetailsPhone(
          categoryNameTextController: categoryNameTextController,
          selectedCategoryIconName: selectedCategoryIconName,
          onSaveTap: () => onSaveTap(index: index),
          onDeleteTap: () => onDeleteTap(categoryId: category.id),
          formKey: formKey,
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return CategoryDetails(
            categoryNameTextController: categoryNameTextController,
            selectedCategoryIconName: selectedCategoryIconName,
            onSaveTap: () => onSaveTap(index: index),
            onDeleteTap: () => onDeleteTap(categoryId: category.id),
            formKey: formKey,
          );
        },
      );
    }
  }
}
