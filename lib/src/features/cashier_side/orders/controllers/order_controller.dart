import 'dart:async';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/choose_customer_phone.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/passcode_screen.dart';

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
  final RxString currentCustomerName = 'guest'.tr.obs;
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
  final RxBool loadingCategories = true.obs;
  final RxBool loadingItems = true.obs;
  final RxDouble orderSubtotal = 0.0.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble orderTotal = 0.0.obs;
  final RxDouble orderTax = 0.0.obs;
  final double taxRate = 0;

  late final StreamController<bool> verificationNotifier;
  @override
  void onInit() async {
    searchBarTextController = TextEditingController();
    discountTextController = TextEditingController();
    verificationNotifier = StreamController<bool>.broadcast();
    if (orderModel.discountType != null && orderModel.discountValue != null) {
      discountType = orderModel.discountType!;
      discountValue = orderModel.discountValue!;
    }
    if (orderModel.items.isNotEmpty) {
      orderItems.value = orderModel.items;
      calculateTotalAmount();
    }
    if (orderModel.customerName != null) {
      currentCustomerName.value = orderModel.customerName!;
    }
    super.onInit();
  }

  @override
  void onReady() async {
    searchBarTextController.addListener(() {
      if (!loadingCategories.value && !loadingItems.value) {
        final searchText = searchBarTextController.text.trim().toUpperCase();
        filteredItems.value = searchText.isEmpty
            ? categoryFilteredItems
            : categoryFilteredItems
                .where((item) => item.name.toUpperCase().contains(searchText))
                .toList();
      }
    });
    loadCategories();
    loadItems();
    super.onReady();
  }

  void loadItems() async {
    final itemsFetch = await fetchItems();

    if (itemsFetch != null) {
      loadingItems.value = false;
      items = itemsFetch;
      categoryFilteredItems = itemsFetch;
      filteredItems.value = items;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<List<ItemModel>?> fetchItems() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('items').get();
      return querySnapshot.docs.map((doc) {
        return ItemModel.fromFirestore(doc.data(), doc.id);
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

  void loadCategories() async {
    final categoriesFetch = await fetchCategories();
    if (categoriesFetch != null) {
      loadingCategories.value = false;
      categoriesFetch.insert(
          0, CategoryModel(id: 'all', name: 'allMenu'.tr, iconName: 'allMenu'));
      categories.value = categoriesFetch;
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<List<CategoryModel>?> fetchCategories() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore.collection('categories').get();
      return querySnapshot.docs.map((doc) {
        return CategoryModel.fromFirestore(doc.data(), doc.id);
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

  void onCategorySelect(int selectedCatIndex) {
    if (!loadingItems.value) {
      selectedCategory.value = selectedCatIndex;
      categoryFilteredItems = selectedCatIndex == 0
          ? items
          : items
              .where(
                  (item) => item.categoryId == categories[selectedCatIndex].id)
              .toList();
      final searchText = searchBarTextController.text.trim().toUpperCase();
      filteredItems.value = searchText.isEmpty
          ? categoryFilteredItems
          : categoryFilteredItems
              .where((item) => item.name.toUpperCase().contains(searchText))
              .toList();
    }
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

  void onCustomerChoose(BuildContext context) async {
    final isPhone = GetScreenType(context).isPhone;
    final CustomerModel? customer = isPhone
        ? await Get.to(
            () => const ChooseCustomerPhone(),
            transition: getPageTransition(),
          )
        : await showDialog(
            useSafeArea: true,
            context: context,
            builder: (context) {
              return const ChooseCustomer();
            },
          );
    if (customer != null) {
      showLoadingScreen();
      final addStatus = await addCustomerToOrder(
          customer: customer, orderId: orderModel.orderId);
      hideLoadingScreen();
      if (addStatus == FunctionStatus.success) {
        orderModel.customerName = customer.name;
        orderModel.customerId = customer.customerId;
        orderModel.discountValue = customer.discountValue;
        orderModel.discountType = customer.discountType;
        currentCustomer = customer;
        currentCustomerName.value = currentCustomer!.name;
        discountValue = currentCustomer!.discountValue;
        discountType = currentCustomer!.discountType;
        calculateTotalAmount();
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
      await firestore.collection('orders').doc(orderId).update(
        {
          'customerId': customer.customerId,
          'customerName': customer.name,
          'discountValue': customer.discountValue,
          'discountType': customer.discountType,
        },
      );
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
        'customerName': null,
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
      orderModel.customerName = null;
      orderModel.customerId = null;
      orderModel.discountValue = null;
      orderModel.discountType = null;
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

  void onEditItemPress(int index, BuildContext context, bool isPhone) async {
    if (hasPermission(AuthenticationRepository.instance.employeeInfo,
        UserPermission.editOrderItemsWithPass)) {
      final passcodeValid = await showPassCodeScreen(index, context);
      if (passcodeValid) {
        if (Get.context!.mounted) {
          editItem(index, context, isPhone);
        }
      }
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<bool> showPassCodeScreen(int index, BuildContext context) async {
    bool valid = false;
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return PasscodeScreen(
          digits: isLangEnglish()
              ? ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
              : ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٠'],
          title: Text(
            'enterPasscode'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          passwordEnteredCallback: (String enteredPasscode) {
            bool isValid = MainScreenController.instance
                .verifyEditOrderItemPasscode(enteredPasscode);
            verificationNotifier.add(isValid);
          },
          cancelButton: Text(
            'cancel'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          isValidCallback: () => valid = true,
          cancelCallback: () => Get.back(),
          deleteButton: Text(
            'delete'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          shouldTriggerVerification: verificationNotifier.stream,
        );
      },
    );
    return valid;
  }

  Future<bool> onDeleteItem(
      int itemIndex, BuildContext context, OrderItemModel orderItem) async {
    if (hasPermission(AuthenticationRepository.instance.employeeInfo,
        UserPermission.editOrderItemsWithPass)) {
      final passcodeValid = await showPassCodeScreen(itemIndex, context);
      if (passcodeValid) {
        final itemDeleted = await deleteItem(itemIndex, orderItem);
        return itemDeleted;
      } else {
        return false;
      }
    } else {
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
      return false;
    }
  }

  Future<bool> deleteItem(int itemIndex, OrderItemModel orderItem) async {
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

  void editItem(int index, BuildContext context, bool isPhone) async {
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

  onQuantityChangedPhone(
      int newQuantity, int index, BuildContext context) async {
    if (hasPermission(AuthenticationRepository.instance.employeeInfo,
        UserPermission.editOrderItemsWithPass)) {
      final passcodeValid = await showPassCodeScreen(index, context);
      if (passcodeValid) {
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
          orderItems[index] = orderItems[index];
          calculateTotalAmount();
        } else {
          orderItems[index].quantity = newQuantity > orderItems[index].quantity
              ? newQuantity - 1
              : newQuantity + 1;
          orderItems[index] = orderItems[index];
          showSnackBar(
            text: 'errorOccurred'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      } else {
        orderItems[index].quantity = newQuantity > orderItems[index].quantity
            ? newQuantity - 1
            : newQuantity + 1;
        orderItems[index] = orderItems[index];
      }
    } else {
      orderItems[index].quantity = newQuantity > orderItems[index].quantity
          ? newQuantity - 1
          : newQuantity + 1;
      orderItems[index] = orderItems[index];
      showSnackBar(
        text: 'functionNotAllowed'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  void onClose() async {
    verificationNotifier.close();
    super.onClose();
  }
}
