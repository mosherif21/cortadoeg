import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
  int itemQuantity = 1;
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
      selectedSugarLevel = orderItemModel!.sugarLevel;
      notesTextController.text = orderItemModel!.note;
    } else {
      selectedSizeString = itemSizesStringList[0];
      selectedSugarLevel = sugarLevelsStringList[0];
    }

    super.onInit();
  }

  String formattedSize(String size, double price) {
    return '$size - \$${price.toStringAsFixed(2)}';
  }

  void onAddTap() {
    final selectedSizeIndex = itemSizesStringList.indexOf(selectedSizeString!);
    final selectedSize = itemModel.sizes[selectedSizeIndex];
    final orderItem = OrderItemModel(
      note: notesTextController.text.trim(),
      itemImageUrl: itemModel.imageUrl,
      itemId: itemModel.id,
      name: itemModel.name,
      size: selectedSize.name,
      quantity: itemQuantity,
      options: selectedOptions,
      sugarLevel: selectedSugarLevel!,
      price: selectedSize.price,
    );
    Get.back(result: orderItem);
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
