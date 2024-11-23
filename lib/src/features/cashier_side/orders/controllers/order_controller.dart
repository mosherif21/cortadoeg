import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer_phone.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/discount_widget.dart';
import '../components/item_details.dart';
import '../components/item_details_phone.dart';
import '../components/models.dart';

class OrderController extends GetxController {
  OrderController({
    required this.orderModel,
  });

  final OrderModel orderModel;
  final selectedCategory = 0.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  late final List<ItemModel> items;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxString currentCustomerName = ''.obs;
  CustomerModel? currentCustomer;
  late List<ItemModel> categoryFilteredItems;
  final RxList<ItemModel> filteredItems = <ItemModel>[].obs;
  final RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;
  List<String> tableIds = [];
  late final TextEditingController discountTextController;
  late final TextEditingController searchBarTextController;
  late final DraggableScrollableController phoneItemDetailsScrollController;
  String? discountType;
  double? discountValue;
  late String? userId;
  int quantity = 1;
  final RxBool addingDiscount = false.obs;
  final RxBool percentageChosen = true.obs;
  final RxDouble orderSubtotal = 0.0.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble orderTotal = 0.0.obs;
  final RxDouble orderTax = 0.0.obs;
  final double taxRate = 0;

  @override
  void onInit() async {
    searchBarTextController = TextEditingController();
    discountTextController = TextEditingController();
    categories.value = categoriesExample;
    items = cafeItemsExample;
    customers.value = MainScreenController.instance.customersList;
    currentCustomerName.value = 'guest'.tr;
    categoryFilteredItems = cafeItemsExample;
    filteredItems.value = items;
    if (orderModel.customerId != null) {
      currentCustomer = customers.where((customer) {
        return customer.customerId == orderModel.customerId;
      }).first;
      if (currentCustomer != null) {
        currentCustomerName.value = currentCustomer!.name;
      }
    }
    if (orderModel.discountType != null && orderModel.discountValue != null) {
      discountType = orderModel.discountType!;
      discountValue = orderModel.discountValue!;
    }
    if (orderModel.items.isNotEmpty) {
      orderItems.value = orderModel.items;
      calculateTotalAmount();
    }

    super.onInit();
  }

  @override
  void onReady() {
    searchBarTextController.addListener(() {
      final searchText = searchBarTextController.text.trim().toUpperCase();
      filteredItems.value = searchText.isEmpty
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
    filteredItems.value = searchText.isEmpty
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

  void onItemSelected(BuildContext context, int index, bool isPhone) async {
    final orderItem = !isPhone
        ? await showDialog(
            useSafeArea: true,
            context: context,
            builder: (context) {
              return ItemDetails(
                item: filteredItems[index],
              );
            },
          )
        : await showFlexibleBottomSheet(
            bottomSheetColor: Colors.transparent,
            minHeight: 0,
            initHeight: 0.75,
            maxHeight: 1,
            anchors: [0, 0.75, 1],
            isSafeArea: true,
            context: context,
            builder: (
              BuildContext context,
              ScrollController scrollController,
              double bottomSheetOffset,
            ) {
              return ItemDetailsPhone(
                item: filteredItems[index],
              );
            },
          );

    if (orderItem != null) {
      orderItems.add(orderItem);
      calculateTotalAmount();
      AppInit.logger.i('Order Total is $orderTotal');
      final ordersList = MainScreenController.instance.ordersList;
      final orderIndex = ordersList.indexWhere((order) {
        return order.orderId == orderModel.orderId;
      });
      ordersList[orderIndex].items = orderItems;
    }
  }

  double calculateTotalAmount() {
    orderSubtotal.value = orderItems.fold(
        0, (addition, item) => addition + item.price * item.quantity);
    discountAmount.value = 0.0;
    if (discountType != null && discountValue != null) {
      if (discountType == 'percentage') {
        discountAmount.value = orderSubtotal.value * (discountValue! / 100);
      } else if (discountType == 'value') {
        discountAmount.value = discountValue!;
      }
    }
    final taxableAmount = (orderSubtotal.value - discountAmount.value) < 0
        ? 0
        : (orderSubtotal.value - discountAmount.value);
    orderTax.value = taxableAmount * (taxRate / 100);
    orderTotal.value = taxableAmount + orderTax.value;
    return orderTotal.value;
  }

  void onDeleteItem(int itemIndex) {
    orderItems.removeAt(itemIndex);
    calculateTotalAmount();
  }

  void onCustomerChoose(BuildContext context) async {
    final isPhone = GetScreenType(context).isPhone;
    final CustomerModel? customer = isPhone
        ? await Get.to(
            () => ChooseCustomerPhone(customers: customers),
            transition: getPageTransition(),
          )
        : await showDialog(
            useSafeArea: true,
            context: context,
            builder: (context) {
              return ChooseCustomer(customers: customers);
            },
          );
    if (customer != null) {
      currentCustomer = customer;
      currentCustomerName.value = currentCustomer!.name;
      discountValue = currentCustomer!.discountValue;
      discountType = currentCustomer!.discountType;
      calculateTotalAmount();
      if (!customers.contains(customer)) {
        customers.add(customer);
        MainScreenController.instance.customersList = customers;
      }
      AppInit.logger.i('Customer Added');
      final ordersList = MainScreenController.instance.ordersList;
      final orderIndex = ordersList.indexWhere((order) {
        return order.orderId == orderModel.orderId;
      });
      ordersList[orderIndex].customerId = customer.customerId;
      ordersList[orderIndex].discountValue = customer.discountValue;
      ordersList[orderIndex].discountType = customer.discountType;
    }
  }

  void onRemoveCustomer() async {
    currentCustomer = null;
    currentCustomerName.value = 'guest'.tr;
    discountValue = null;
    discountType = null;
    percentageChosen.value = true;
    discountTextController.text = '';
    calculateTotalAmount();
    final ordersList = MainScreenController.instance.ordersList;
    final orderIndex = ordersList.indexWhere((order) {
      return order.orderId == orderModel.orderId;
    });
    ordersList[orderIndex].customerId = null;
    ordersList[orderIndex].discountValue = null;
    ordersList[orderIndex].discountType = null;
  }

  void onEditItem(int index, BuildContext context, bool isPhone) async {
    final selectedOrderItem = orderItems[index];

    final editedOrderItem = !isPhone
        ? await showDialog(
            useSafeArea: true,
            context: context,
            builder: (context) {
              return ItemDetails(
                item: items.where((item) {
                  return item.itemId == selectedOrderItem.itemId;
                }).first,
                orderItem: selectedOrderItem,
              );
            },
          )
        : await showFlexibleBottomSheet(
            bottomSheetColor: Colors.transparent,
            minHeight: 0,
            initHeight: 0.75,
            maxHeight: 1,
            anchors: [0, 0.75, 1],
            isSafeArea: true,
            context: context,
            builder: (
              BuildContext context,
              ScrollController scrollController,
              double bottomSheetOffset,
            ) {
              return ItemDetailsPhone(
                item: items.where((item) {
                  return item.itemId == selectedOrderItem.itemId;
                }).first,
                orderItem: selectedOrderItem,
              );
            },
          );
    if (editedOrderItem != null) {
      orderItems[index] = editedOrderItem;
      calculateTotalAmount();
      AppInit.logger.i('Order Total is $orderTotal');
      final ordersList = MainScreenController.instance.ordersList;
      final orderIndex = ordersList.indexWhere((order) {
        return order.orderId == orderModel.orderId;
      });
      ordersList[orderIndex].items = orderItems;
    }
  }

  onAddDiscount(type, value) {
    discountType = type;
    discountValue = value;
    addingDiscount.value = false;
    calculateTotalAmount();
    final ordersList = MainScreenController.instance.ordersList;
    final orderIndex = ordersList.indexWhere((order) {
      return order.orderId == orderModel.orderId;
    });
    ordersList[orderIndex].discountValue = discountValue;
    ordersList[orderIndex].discountType = discountType;
  }

  onCancelDiscount() {
    discountValue = null;
    discountType = null;
    percentageChosen.value = true;
    discountTextController.text = '';
    calculateTotalAmount();
    final ordersList = MainScreenController.instance.ordersList;
    final orderIndex = ordersList.indexWhere((order) {
      return order.orderId == orderModel.orderId;
    });
    ordersList[orderIndex].discountValue = null;
    ordersList[orderIndex].discountType = null;
  }

  addDiscount() {
    addingDiscount.value = true;
    if (discountValue != null && discountType != null) {
      percentageChosen.value = discountType!.compareTo('percentage') == 0;
      discountTextController.text =
          discountValue! > 0 ? discountValue.toString() : '';
    }
  }

  addDiscountPhone(BuildContext context) {
    showFlexibleBottomSheet(
      bottomSheetColor: Colors.transparent,
      minHeight: 0,
      initHeight: 1,
      maxHeight: 1,
      anchors: [0, 1],
      isSafeArea: true,
      context: context,
      builder: (
        BuildContext context,
        ScrollController scrollController,
        double bottomSheetOffset,
      ) {
        return Center(
          child: DiscountWidget(
            percentageChosen: percentageChosen,
            discountTextController: discountTextController,
            initialDiscountType: discountType ?? 'percentage',
            initialDiscountValue: discountValue ?? 0,
            onAddDiscount: (type, value) {
              discountType = type;
              discountValue = value;
              calculateTotalAmount();
              final ordersList = MainScreenController.instance.ordersList;
              final orderIndex = ordersList.indexWhere((order) {
                return order.orderId == orderModel.orderId;
              });
              ordersList[orderIndex].discountValue = discountValue;
              ordersList[orderIndex].discountType = discountType;
              Get.back();
            },
            onCancel: () => Get.back(),
          ),
        );
      },
    );
    if (discountValue != null && discountType != null) {
      percentageChosen.value = discountType!.compareTo('percentage') == 0;
      discountTextController.text =
          discountValue! > 0 ? discountValue.toString() : '';
    }
  }

  onQuantityChangedPhone(int newQuantity, int index) {
    orderItems[index].quantity = newQuantity;
    calculateTotalAmount();
    final ordersList = MainScreenController.instance.ordersList;
    final orderIndex = ordersList.indexWhere((order) {
      return order.orderId == orderModel.orderId;
    });
    ordersList[orderIndex].items = orderItems;
  }
}
