import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/models.dart';

class NewOrderController extends GetxController {
  final selectedCategory = 0.obs;
  late final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  late final List<ItemModel> items;
  late List<ItemModel> categoryFilteredItems;
  late final RxList<ItemModel> selectedItems = <ItemModel>[].obs;
  late final TextEditingController searchBarTextController;
  @override
  void onInit() async {
    searchBarTextController = TextEditingController();
    categories.value = [
      CategoryModel(id: '1', name: 'All Menu', iconName: 'allMenu'),
      CategoryModel(id: '2', name: 'Ice Cream', iconName: 'fa_ice_cream'),
      CategoryModel(id: '3', name: 'Coffee', iconName: 'coffee'),
      CategoryModel(id: '4', name: 'Cakes', iconName: 'fa_birthday_cake'),
      CategoryModel(
          id: '4', name: 'Special Cakes', iconName: 'fa_birthday_cake'),
    ];
    items = cafeItemsExample;
    categoryFilteredItems = cafeItemsExample;
    selectedItems.value = items;
    super.onInit();
  }

  @override
  void onReady() {
    searchBarTextController.addListener(() {
      final searchText = searchBarTextController.text.trim().toUpperCase();
      selectedItems.value = searchText.isEmpty
          ? categoryFilteredItems
          : categoryFilteredItems
              .where((item) => item.name.toUpperCase().contains(searchText))
              .toList();
    });
    super.onReady();
  }

  void onCategorySelect(int selectedCatIndex) {
    selectedCategory.value = selectedCatIndex;
    categoryFilteredItems = selectedCatIndex == 0
        ? items
        : items
            .where((item) => item.categoryId == categories[selectedCatIndex].id)
            .toList();
    selectedItems.value = categoryFilteredItems;
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
