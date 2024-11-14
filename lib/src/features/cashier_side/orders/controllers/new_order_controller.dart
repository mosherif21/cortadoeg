import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/item_details.dart';
import '../components/models.dart';

class NewOrderController extends GetxController {
  NewOrderController({
    required this.isTakeaway,
    this.tablesNo,
    required this.currentOrderId,
  });
  final bool isTakeaway;
  final List<int>? tablesNo;
  final String currentOrderId;
  final selectedCategory = 0.obs;
  late final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  late final List<ItemModel> items;
  late List<ItemModel> categoryFilteredItems;
  late final RxList<ItemModel> selectedItems = <ItemModel>[].obs;
  late final RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;
  late List<String> tableIds = [];
  late final TextEditingController searchBarTextController;
  late final OrderModel orderModel;
  String? discountType;
  double? discountValue;
  late String? userId;
  int quantity = 1;
  double orderSubtotal = 0.0;
  double discountAmount = 0.0;
  double orderTotal = 0.0;
  double orderTax = 0.0;
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
    orderModel = OrderModel(
      id: '123',
      tableIds: tableIds,
      items: orderItems,
      status: OrderStatus.active,
      timestamp: Timestamp.now(),
      totalAmount: 0.0,
    );
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
    final searchText = searchBarTextController.text.trim().toUpperCase();
    selectedItems.value = searchText.isEmpty
        ? categoryFilteredItems
        : categoryFilteredItems
            .where((item) => item.name.toUpperCase().contains(searchText))
            .toList();
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }

  void onItemSelected(BuildContext context, int index) async {
    final orderItem = await showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return ItemDetails(
          item: selectedItems[index],
        );
      },
    );
    if (orderItem != null) {
      orderItems.add(orderItem);
      calculateTotalAmount();
      AppInit.logger.i('Order Total is $orderTotal');
    }
  }

  double calculateTotalAmount() {
    orderSubtotal = orderItems.fold(
        0, (addition, item) => addition + item.price * item.quantity);

    discountAmount = 0.0;
    if (discountType != null && discountValue != null) {
      if (discountType == 'manual' && discountValue != null) {
        if (discountType == 'percentage') {
          discountAmount = orderSubtotal * (discountValue! / 100);
        } else if (discountType == 'value') {
          discountAmount = discountValue!;
        }
      }
    }

    return orderTotal = orderSubtotal - discountAmount;
  }

  void onDeleteItem(int itemIndex) {
    orderItems.removeAt(itemIndex);
    calculateTotalAmount();
  }

  void onEditItem(int index, BuildContext context) async {
    final selectedOrderItem = orderItems[index];
    final orderItem = await showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return ItemDetails(
          item: items.where((item) {
            return item.id == selectedOrderItem.itemId;
          }).first,
          orderItem: selectedOrderItem,
        );
      },
    );
    if (orderItem != null) {
      orderItems[index] = orderItem;
      calculateTotalAmount();
      AppInit.logger.i('Order Total is $orderTotal');
    }
  }
}
