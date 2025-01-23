import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';

class OrderItemController extends GetxController {
  final ItemModel itemModel;
  final OrderItemModel? orderItemModel;
  OrderItemController({
    required this.itemModel,
    this.orderItemModel,
  });
  String? selectedSizeString;
  Map<String, String> selectedOptions = {};
  String? selectedSugarLevel;
  late final Rx<ItemSizeModel> selectedSize;
  final RxInt itemQuantity = 1.obs;
  late final List<String> itemSizesStringList;
  late final List<String> sugarLevelsStringList;
  late final TextEditingController notesTextController;

  @override
  void onInit() async {
    notesTextController = TextEditingController();
    itemSizesStringList = itemModel.sizes.map((size) {
      return formattedSize(size.name, size.price);
    }).toList();

    sugarLevelsStringList = itemModel.sugarLevels;
    if (orderItemModel != null) {
      selectedSizeString =
          formattedSize(orderItemModel!.size, orderItemModel!.price);
      selectedSize = itemModel.sizes
          .where((size) =>
              formattedSize(size.name, size.price) ==
              formattedSize(orderItemModel!.size, orderItemModel!.price))
          .first
          .obs;
      selectedSugarLevel = orderItemModel!.sugarLevel;
      notesTextController.text = orderItemModel!.note;
      itemQuantity.value = orderItemModel!.quantity;
    } else {
      selectedSizeString = itemSizesStringList[0];
      selectedSugarLevel = sugarLevelsStringList[0];
      selectedSize = itemModel.sizes[0].obs;
    }
    super.onInit();
  }

  String formattedSize(String size, double price) {
    return '$size - EGP ${price.toStringAsFixed(2)}';
  }

  void onAddTap() {
    final selectedSizeIndex = itemSizesStringList.indexOf(selectedSizeString!);
    final selectedSize = itemModel.sizes[selectedSizeIndex];
    final List<OptionValue> selectedOptionsRecipes = <OptionValue>[];

    for (var entry in selectedOptions.entries) {
      String selectedOptionKey = entry.key;
      String selectedOptionValue = entry.value;

      if (itemModel.options.containsKey(selectedOptionKey)) {
        List<OptionValue> optionValues = itemModel.options[selectedOptionKey]!;

        OptionValue? selectedOptionValueObject = optionValues.firstWhere(
          (option) => option.name == selectedOptionValue,
          orElse: () => OptionValue(name: '', recipe: <RecipeItem>[].obs),
        );

        selectedOptionsRecipes.add(selectedOptionValueObject);
      }
    }

    final orderItem = OrderItemModel(
      note: notesTextController.text.trim(),
      itemImageUrl: itemModel.imageUrl,
      name: itemModel.name,
      size: selectedSize.name,
      quantity: itemQuantity.value,
      options: selectedOptions,
      sugarLevel: selectedSugarLevel!,
      price: selectedSize.price,
      orderItemId: Timestamp.now().seconds.toString(),
      itemId: itemModel.itemId,
      selectedSize: selectedSize,
      selectedOptions: selectedOptionsRecipes,
      costPrice: calculateOrderItemCostPrice(
          selectedSize.costPrice, selectedOptionsRecipes),
    );
    Get.back(result: orderItem);
  }

  double calculateOrderItemCostPrice(
    double sizePrice,
    List<OptionValue> selectedOptions,
  ) {
    double totalCost = sizePrice;
    for (var option in selectedOptions) {
      for (var recipeItem in option.recipe) {
        totalCost +=
            (recipeItem.cost / recipeItem.costQuantity) * recipeItem.quantity;
      }
    }
    return roundToNearestHalfOrWhole(totalCost);
  }

  @override
  void onReady() {
    //
    super.onReady();
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
