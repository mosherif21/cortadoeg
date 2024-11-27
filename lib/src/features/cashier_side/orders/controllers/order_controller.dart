import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer_phone.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
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
    categoryFilteredItems = cafeItemsExample;
    filteredItems.value = items;
    if (orderModel.discountType != null && orderModel.discountValue != null) {
      discountType = orderModel.discountType!;
      discountValue = orderModel.discountValue!;
    }
    if (orderModel.items.isNotEmpty) {
      orderItems.value = orderModel.items;
      calculateTotalAmount();
    }
    customers.value = customersExample;
    currentCustomerName.value = 'guest'.tr;
    if (orderModel.customerId != null) {
      currentCustomer = customers.where((customer) {
        return customer.customerId == orderModel.customerId;
      }).first;
      if (currentCustomer != null) {
        currentCustomerName.value = currentCustomer!.name;
      }
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
      showLoadingScreen();
      final addItemStatus =
          await addOrderItem(orderItem: orderItem, orderId: orderModel.orderId);
      hideLoadingScreen();
      if (addItemStatus == FunctionStatus.success) {
        orderItems.add(orderItem);
        calculateTotalAmount();
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> addOrderItem(
      {required OrderItemModel orderItem, required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').doc(orderId).update({
        'items': FieldValue.arrayUnion([orderItem.toFirestore()]),
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<FunctionStatus> deleteOrderItem(
      {required OrderItemModel orderItem, required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').doc(orderId).update({
        'items': FieldValue.arrayRemove([orderItem.toFirestore()]),
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
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

  Future<bool> onDeleteItem(int itemIndex, OrderItemModel orderItem) async {
    showLoadingScreen();
    final addItemStatus = await deleteOrderItem(
        orderItem: orderItem, orderId: orderModel.orderId);
    hideLoadingScreen();
    if (addItemStatus == FunctionStatus.success) {
      orderItems.removeAt(itemIndex);
      calculateTotalAmount();
      showSnackBar(
        text: 'orderItemDeletedSuccess'.tr,
        snackBarType: SnackBarType.success,
      );
      return true;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
      return false;
    }
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
      showLoadingScreen();
      final addStatus = await addCustomerToOrder(
          customer: customer, orderId: orderModel.orderId);
      hideLoadingScreen();
      if (addStatus == FunctionStatus.success) {
        currentCustomer = customer;
        currentCustomerName.value = currentCustomer!.name;
        discountValue = currentCustomer!.discountValue;
        discountType = currentCustomer!.discountType;
        calculateTotalAmount();
        if (!customers.contains(customer)) {
          customers.add(customer);
        }
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> addCustomerToOrder(
      {required CustomerModel customer, required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.update(
        firestore.collection('orders').doc(orderId),
        {
          'customerId': customer.customerId,
          'discountValue': customer.discountValue,
          'discountType': customer.discountType,
        },
      );
      if (!customers.contains(customer)) {
        final newCustomerDoc = firestore.collection('customers').doc();
        customer.customerId = newCustomerDoc.id;
        batch.set(
          newCustomerDoc,
          customer.toFirestore(),
        );
      }
      await batch.commit();
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<FunctionStatus> removeCustomerFromOrder(
      {required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').doc(orderId).update({
        'customerId': null,
        'discountValue': null,
        'discountType': null,
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  void onRemoveCustomer() async {
    showLoadingScreen();
    final removeStatus =
        await removeCustomerFromOrder(orderId: orderModel.orderId);
    hideLoadingScreen();
    if (removeStatus == FunctionStatus.success) {
      currentCustomer = null;
      currentCustomerName.value = 'guest'.tr;
      discountValue = null;
      discountType = null;
      percentageChosen.value = true;
      discountTextController.text = '';
      calculateTotalAmount();
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
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
      showLoadingScreen();
      final editOrderItemStatus = await editOrderItemQuantity(
        orderId: orderModel.orderId,
        orderItems: orderItems,
        editedOrderItem: editedOrderItem,
        index: index,
      );
      hideLoadingScreen();
      if (editOrderItemStatus == FunctionStatus.success) {
        orderItems[index] = editedOrderItem;
        calculateTotalAmount();
      } else {
        showSnackBar(
          text: 'errorOccurred'.tr,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<FunctionStatus> editOrderItemQuantity({
    required String orderId,
    required List<OrderItemModel> orderItems,
    required OrderItemModel editedOrderItem,
    required int index,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      orderItems[index] = editedOrderItem;
      await firestore.collection('orders').doc(orderId).update({
        'items': orderItems.map((item) => item.toFirestore()).toList(),
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  onAddDiscount(type, value) async {
    showLoadingScreen();
    final addDiscountStatus = await addDiscountDatabase(
        orderId: orderModel.orderId, discountValue: value, discountType: type);
    hideLoadingScreen();
    if (addDiscountStatus == FunctionStatus.success) {
      discountType = type;
      discountValue = value;
      addingDiscount.value = false;
      calculateTotalAmount();
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> addDiscountDatabase({
    required String orderId,
    required double discountValue,
    required String discountType,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').doc(orderId).update({
        'discountValue': discountValue,
        'discountType': discountType,
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  onCancelDiscount() async {
    showLoadingScreen();
    final removeDiscountStatus =
        await removeDiscountDatabase(orderId: orderModel.orderId);
    hideLoadingScreen();
    if (removeDiscountStatus == FunctionStatus.success) {
      discountValue = null;
      discountType = null;
      percentageChosen.value = true;
      discountTextController.text = '';
      calculateTotalAmount();
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> removeDiscountDatabase(
      {required String orderId}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('orders').doc(orderId).update({
        'discountValue': null,
        'discountType': null,
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
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
            onAddDiscount: (type, value) async {
              showLoadingScreen();
              final addDiscountStatus = await addDiscountDatabase(
                  orderId: orderModel.orderId,
                  discountValue: value,
                  discountType: type);
              hideLoadingScreen();
              if (addDiscountStatus == FunctionStatus.success) {
                discountType = type;
                discountValue = value;
                calculateTotalAmount();
                Get.back();
              } else {
                showSnackBar(
                  text: 'errorOccurred'.tr,
                  snackBarType: SnackBarType.error,
                );
              }
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

  Future<FunctionStatus> changeOrderItemQuantity({
    required String orderId,
    required List<OrderItemModel> orderItems,
    required int newQuantity,
    required int index,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      orderItems[index].quantity = newQuantity;
      await firestore.collection('orders').doc(orderId).update({
        'items': orderItems.map((item) => item.toFirestore()).toList(),
      });
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
      return FunctionStatus.failure;
    }
  }

  onQuantityChangedPhone(int newQuantity, int index) async {
    showLoadingScreen();
    final changeQuantityStatus = await changeOrderItemQuantity(
      orderId: orderModel.orderId,
      orderItems: orderItems,
      newQuantity: newQuantity,
      index: index,
    );
    hideLoadingScreen();
    if (changeQuantityStatus == FunctionStatus.success) {
      orderItems[index].quantity = newQuantity;
      calculateTotalAmount();
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }
}
