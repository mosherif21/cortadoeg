import 'dart:async';
import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/features/admin_side/inventory/components/models.dart';
import 'package:cortadoeg/src/features/admin_side/menu_items/components/choose_recipe_product.dart';
import 'package:cortadoeg/src/features/admin_side/menu_items/components/recipe_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sweetsheet/sweetsheet.dart';

import '../../../../constants/enums.dart';
import '../../../../general/app_init.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/account/components/photo_select.dart';
import '../../../cashier_side/account/components/photo_select_phone.dart';
import '../../../cashier_side/orders/components/models.dart';
import '../components/manage_item.dart';
import '../components/manage_item_phone.dart';
import '../components/recipe_widget_phone.dart';

class ItemsScreenController extends GetxController {
  static ItemsScreenController get instance => Get.find();

  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxBool loadingItems = false.obs;
  final int pageSize = 10;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  Timer? _searchDebounce;
  String searchText = '';
  final RefreshController itemRefreshController =
      RefreshController(initialRefresh: false);

  final TextEditingController itemNameTextController = TextEditingController();
  final TextEditingController itemDescriptionTextController =
      TextEditingController();
  final selectedCategoryIndex = 0.obs;
  final categoryFilterIndex = 0.obs;
  final RxBool loadingCategories = true.obs;
  final RxList<ItemSizeModel> itemSizes = <ItemSizeModel>[].obs;
  RxList<MapEntry<String, RxList<OptionValue>>> options =
      RxList<MapEntry<String, RxList<OptionValue>>>([]);

  final RxList<String> itemSugarLevels = <String>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  late final GlobalKey<FormState> recipeQuantityKey;
  final List<Map<String, TextEditingController>> sizeControllers = [];
  final List<TextEditingController> sugarLevelControllers = [];
  final List<List<TextEditingController>> optionValueControllers = [];
  final List<TextEditingController> optionKeyControllers = [];
  final List<TextEditingController> recipeQuantityControllers = [];

  //item image values
  final Rx<XFile?> itemImage = Rx<XFile?>(null);
  final Rxn<ImageProvider> itemMemoryImage = Rxn<ImageProvider>(null);
  final isItemImageLoaded = false.obs;
  final isItemImageChanged = false.obs;
  final picker = ImagePicker();
  String itemImageUrl = '';
  late final FirebaseStorage fireStorage;

  @override
  void onInit() {
    recipeQuantityKey = GlobalKey<FormState>();
    super.onInit();
  }

  @override
  void onReady() {
    loadCategories();
    fetchItems();
    super.onReady();
  }

  void onEditItemImageTap({required bool isPhone, required String itemId}) {
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        PhotoSelectPhone(
          headerText: 'chooseItemPicMethod'.tr,
          onCapturePhotoPress: () =>
              captureItemPic(isPhone: isPhone, itemId: itemId),
          onChoosePhotoPress: () =>
              pickItemPic(isPhone: isPhone, itemId: itemId),
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return PhotoSelect(
            headerText: 'chooseItemPicMethod'.tr,
            onCapturePhotoPress: () =>
                captureItemPic(isPhone: isPhone, itemId: itemId),
            onChoosePhotoPress: () =>
                pickItemPic(isPhone: isPhone, itemId: itemId),
          );
        },
      );
    }
  }

  void loadProfileImage({required String imageUrl}) async {
    try {
      if (imageUrl.trim().isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          itemMemoryImage.value = MemoryImage(imageBytes);
          if (kDebugMode) AppInit.logger.i('Item image loaded successfully');
        } else {
          if (kDebugMode) AppInit.logger.e('Failed to load Item image');
        }
      } else {
        if (kDebugMode) AppInit.logger.e('Item doesn\'t have a profile image');
      }
      isItemImageLoaded.value = true;
    } on FirebaseException catch (error) {
      if (kDebugMode) AppInit.logger.e(error.toString());
      isItemImageLoaded.value = true;
    } catch (e) {
      if (kDebugMode) AppInit.logger.e(e.toString());
      isItemImageLoaded.value = true;
    }
  }

  Future<void> pickItemPic(
      {required bool isPhone, required String itemId}) async {
    isPhone ? RegularBottomSheet.hideBottomSheet() : Get.back();
    final addedImage = await picker.pickImage(source: ImageSource.gallery);
    if (addedImage != null) {
      itemImage.value = addedImage;
      showLoadingScreen();
      final saveStatus = await saveItemImage(itemId: itemId);
      hideLoadingScreen();
      if (saveStatus == FunctionStatus.success) {
        isItemImageChanged.value = true;
        showSnackBar(
            text: 'itemImageChangeSuccess'.tr,
            snackBarType: SnackBarType.success);
      } else {
        showSnackBar(
            text: 'itemImageChangeFail'.tr, snackBarType: SnackBarType.error);
      }
    }
  }

  Future<void> captureItemPic(
      {required bool isPhone, required String itemId}) async {
    isPhone ? RegularBottomSheet.hideBottomSheet() : Get.back();
    if (await handleCameraPermission()) {
      final addedImage = await picker.pickImage(source: ImageSource.camera);
      if (addedImage != null) {
        itemImage.value = addedImage;
        showLoadingScreen();
        final saveStatus = await saveItemImage(itemId: itemId);
        hideLoadingScreen();
        if (saveStatus == FunctionStatus.success) {
          isItemImageChanged.value = true;
          showSnackBar(
              text: 'itemImageChangeSuccess'.tr,
              snackBarType: SnackBarType.success);
        } else {
          showSnackBar(
              text: 'itemImageChangeFail'.tr, snackBarType: SnackBarType.error);
        }
      }
    }
  }

  Future<FunctionStatus> saveItemImage({required String itemId}) async {
    try {
      final File file = File(itemImage.value!.path);
      final String fileName = 'items/$itemId/pic';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(file);
      await uploadTask;
      final String downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .update({'imageUrl': downloadUrl});
      isItemImageChanged.value = false;
      return FunctionStatus.success;
    } on FirebaseException catch (e) {
      AppInit.logger.e("An unexpected error occurred: ${e.message}");
    } catch (e) {
      AppInit.logger.e("An unexpected error occurred: $e");
    }
    return FunctionStatus.failure;
  }

  void initializeItem(ItemModel item) {
    itemNameTextController.text = item.name;
    itemDescriptionTextController.text = item.description;
    if (item.categoryId.isNotEmpty) {
      selectedCategoryIndex.value =
          categories.indexWhere((category) => category.id == item.categoryId);
    } else {
      selectedCategoryIndex.value = 1;
    }

    itemSugarLevels.value = item.sugarLevels;
    itemSizes.value = item.sizes
        .map((size) => ItemSizeModel(
              name: size.name,
              price: size.price,
              costPrice: size.costPrice,
              recipe: size.recipe,
            ))
        .toList();

    options.clear();
    options.addAll(
      item.options.entries.map(
        (entry) => MapEntry<String, RxList<OptionValue>>(
          entry.key,
          entry.value.obs,
        ),
      ),
    );
    itemImageUrl = item.imageUrl ?? '';
    loadProfileImage(imageUrl: item.imageUrl ?? '');
  }

  ItemModel getUpdatedItem(String itemId) {
    return ItemModel(
      itemId: itemId,
      imageUrl: itemImageUrl.isEmpty ? null : itemImageUrl,
      name: itemNameTextController.text.trim(),
      description: itemDescriptionTextController.text.trim(),
      categoryId: categories[selectedCategoryIndex.value].id,
      sizes: itemSizes
          .map((size) => ItemSizeModel(
                name: size.name,
                price: size.price,
                costPrice: size.costPrice,
                recipe: size.recipe,
              ))
          .toList(),
      options: {for (var entry in options) entry.key: entry.value.toList().obs},
      sugarLevels: List<String>.from(itemSugarLevels),
    );
  }

  void loadCategories() async {
    loadingCategories.value = true;
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
      final querySnapshot = await firestore
          .collection('categories')
          .orderBy('name_lowercase')
          .get();
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
      categoryFilterIndex.value = selectedCatIndex;
      fetchItems(reset: true);
    }
  }

  void onItemsSearch(String value) {
    if (value.trim().isEmpty) {
      if (searchText.isNotEmpty) {
        searchText = '';
        if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
        fetchItems(reset: true);
      }
    } else {
      searchText = value;
      if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        fetchItems(reset: true);
      });
    }
  }

  Future<void> fetchItems({bool reset = false}) async {
    if (loadingItems.value || (!reset && !hasMore)) return;

    if (reset) {
      items.clear();
      loadingItems.value = true;
      lastDocument = null;
      hasMore = true;
    }
    try {
      Query query = FirebaseFirestore.instance
          .collection('items')
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
      if (categoryFilterIndex.value != 0) {
        final category = categories[categoryFilterIndex.value];
        query = query.where('categoryId', isEqualTo: category.id);
      }
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        final fetchedItems = snapshot.docs.map((doc) {
          return ItemModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        items.addAll(fetchedItems);
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
      loadingItems.value = false;
    }
  }

  void onRefresh() async {
    loadCategories();
    fetchItems(reset: true);
    itemRefreshController.refreshCompleted();
  }

  void onLoadMore() async {
    fetchItems();
    itemRefreshController.loadComplete();
  }

  void clearItemSelectValues() {
    optionKeyControllers.clear();
    optionValueControllers.clear();
    sizeControllers.clear();
    sugarLevelControllers.clear();
    itemImage.value = null;
    itemMemoryImage.value = null;
    isItemImageLoaded.value = false;
    isItemImageChanged.value = false;
    itemImageUrl = '';
  }

  Future<void> addItemTap({required bool isPhone}) async {
    final newItem = ItemModel(
        itemId: '',
        name: 'newItem'.tr,
        categoryId: '',
        description: '',
        sizes: [
          ItemSizeModel(
              name: '${'newSize'.tr} 1',
              price: 0,
              costPrice: 0,
              recipe: RxList<RecipeItem>([]))
        ],
        sugarLevels: [
          '${'newSugarLevel'.tr} 1'
        ]);
    initializeItem(newItem);
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.75,
        maxHeight: 1,
        anchors: [0, 0.75, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return ManageItemDetailsPhone(
            controller: this,
            scrollController: scrollController,
            edit: false,
            itemIndex: 0,
          );
        },
      );
      clearItemSelectValues();
    } else {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return ManageItemDetails(
            controller: this,
            edit: false,
            itemIndex: 0,
          );
        },
      );
      clearItemSelectValues();
    }
  }

  Future<void> addItem() async {
    showLoadingScreen();
    final addedItem = getUpdatedItem('');
    final addedItemId = await addItemDatabase(addedItem);
    hideLoadingScreen();
    if (addedItemId != null) {
      Get.back();
      addedItem.itemId = addedItemId;
      items.add(addedItem);
      showSnackBar(
        text: 'menuItemAddedSuccessfully'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<String?> addItemDatabase(ItemModel item) async {
    final itemsCollectionRef = FirebaseFirestore.instance.collection('items');
    try {
      final doc = await itemsCollectionRef.add(item.toFirestore());
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

  Future<void> onItemTap({required bool isPhone, required int index}) async {
    final chosenItem = items[index];
    initializeItem(chosenItem);
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.75,
        maxHeight: 1,
        anchors: [0, 0.75, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return ManageItemDetailsPhone(
            controller: this,
            scrollController: scrollController,
            edit: true,
            itemIndex: index,
          );
        },
      );
      clearItemSelectValues();
    } else {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return ManageItemDetails(
            controller: this,
            edit: true,
            itemIndex: index,
            imageUrl: chosenItem.imageUrl,
          );
        },
      );
      clearItemSelectValues();
    }
  }

  Future<void> editItem({required int itemIndex}) async {
    showLoadingScreen();
    final itemId = items[itemIndex].itemId;
    final updatedItem = getUpdatedItem(itemId);
    final updateStatus = await updateItem(itemId, updatedItem.toFirestore());
    hideLoadingScreen();
    if (updateStatus == FunctionStatus.success) {
      Get.back();
      if (categoryFilterIndex.value != 0 &&
          updatedItem.categoryId != categories[categoryFilterIndex.value].id) {
        items.removeAt(itemIndex);
      } else {
        items[itemIndex] = updatedItem;
      }
      showSnackBar(
        text: 'menuItemUpdatedSuccessfully'.tr,
        snackBarType: SnackBarType.success,
      );
    } else {
      showSnackBar(
        text: 'errorOccurred'.tr,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<FunctionStatus> updateItem(
      String itemId, Map<String, dynamic> itemData) async {
    final itemsCollectionRef = FirebaseFirestore.instance.collection('items');
    try {
      await itemsCollectionRef.doc(itemId).update(itemData);
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

  Future<FunctionStatus> deleteItem(String itemId) async {
    final itemsCollectionRef = FirebaseFirestore.instance.collection('items');
    try {
      await itemsCollectionRef.doc(itemId).delete();
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

  void onDeleteItemTap(int itemIndex) {
    displayAlertDialog(
      title: 'deleteItem'.tr,
      body: 'deleteItemConfirm'.tr,
      positiveButtonText: 'yes'.tr,
      negativeButtonText: 'no'.tr,
      positiveButtonOnPressed: () async {
        final itemId = items[itemIndex].itemId;
        final result = await deleteItem(itemId);
        if (result == FunctionStatus.success) {
          items.removeAt(itemIndex);
          Get.close(2);
        } else {
          showSnackBar(
            text: 'errorOccurred'.tr,
            snackBarType: SnackBarType.error,
          );
        }
      },
      negativeButtonOnPressed: () => Get.back(),
      mainIcon: Icons.logout,
      color: CustomSheetColor(
          main: Colors.black, accent: Colors.black, icon: Colors.white),
    );
  }

  void addSize() {
    itemSizes.add(ItemSizeModel(
        name: '${'newSize'.tr} ${itemSizes.length + 1}',
        price: 0.0,
        costPrice: 0.0,
        recipe: RxList<RecipeItem>([])));
  }

  void deleteSize(int index) {
    if (itemSizes.length > 1) {
      itemSizes.removeAt(index);
      sizeControllers.removeAt(index);
    } else {
      showSnackBar(
        text: 'mustHaveOneSize'.tr,
        snackBarType: SnackBarType.warning,
      );
    }
  }

  void updateOption(String key, OptionValue? value) {
    if (value != null) {
      final entry = options.firstWhere(
        (entry) => entry.key == key,
        orElse: () =>
            MapEntry<String, RxList<OptionValue>>(key, RxList<OptionValue>()),
      );

      final optionList = entry.value;

      if (!optionList.contains(value)) {
        optionList.add(value);
      } else {
        optionList.clear();
        optionList.add(value);
      }
    }
  }

  void addOptionKey() {
    final RxList<OptionValue> list = <OptionValue>[
      OptionValue(
          name: '${'newOption'.tr} ${options.length + 1}',
          recipe: RxList<RecipeItem>([]))
    ].obs;
    options.add(MapEntry('${'newOption'.tr} ${options.length + 1}', list));
  }

  void updateOptionKey(int optionIndex, String newKey) {
    options[optionIndex] = MapEntry(newKey, options[optionIndex].value);
    update();
  }

  void addOptionValue(int optionIndex) {
    optionValueControllers[optionIndex]
        .add(TextEditingController(text: 'newValue'.tr));
    options[optionIndex]
        .value
        .add(OptionValue(name: '', recipe: RxList<RecipeItem>([])));
    update();
  }

  void updateOptionValueName(int optionIndex, int valueIndex, String newValue) {
    options[optionIndex].value[valueIndex].name = newValue;
    update();
  }

  void onEditSizeRecipeTap(bool isPhone, int sizeIndex) async {
    final chosenSizeRecipe = itemSizes[sizeIndex].recipe;
    initializeRecipe(chosenSizeRecipe);
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.75,
        maxHeight: 1,
        anchors: [0, 0.75, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return RecipePhoneWidgetPhone(
            recipeQuantityKey: recipeQuantityKey,
            recipeItems: chosenSizeRecipe,
            scrollController: scrollController,
            quantityControllers: recipeQuantityControllers,
            optionIndex: sizeIndex,
            onProductQuantityChanged: (recipeIndex, newQuantity) {
              if (recipeQuantityKey.currentState!.validate()) {
                chosenSizeRecipe[recipeIndex].quantity = int.parse(newQuantity);
                itemSizes[sizeIndex].costPrice =
                    calculateCostPriceForSize(itemSizes[sizeIndex]);
                sizeControllers[sizeIndex].values.elementAt(2).text =
                    itemSizes[sizeIndex].costPrice.toStringAsFixed(2);
              }
            },
            onChangeRecipeProductTap: (recipeIndex) async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers[recipeIndex] =
                    TextEditingController(text: '0');
                chosenSizeRecipe[recipeIndex] = RecipeItem(
                  productId: product.id,
                  productName: product.name,
                  costQuantity: product.costQuantity,
                  cost: product.cost,
                  quantity: 0,
                  measuringUnit: product.measuringUnit,
                );
              }
            },
            onDeleteRecipeProductTap: (recipeIndex) {
              chosenSizeRecipe.removeAt(recipeIndex);
              recipeQuantityControllers.removeAt(recipeIndex);
              itemSizes[sizeIndex].costPrice =
                  calculateCostPriceForSize(itemSizes[sizeIndex]);
              sizeControllers[sizeIndex].values.elementAt(2).text =
                  itemSizes[sizeIndex].costPrice.toStringAsFixed(2);
            },
            onAddRecipeProductTap: () async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers.add(TextEditingController(text: '0'));
                chosenSizeRecipe.add(
                  RecipeItem(
                    productId: product.id,
                    productName: product.name,
                    costQuantity: product.costQuantity,
                    cost: product.cost,
                    quantity: 0,
                    measuringUnit: product.measuringUnit,
                  ),
                );
              }
            },
          );
        },
      );
      Timer(const Duration(milliseconds: 200), () {
        recipeQuantityControllers.clear();
      });
    } else {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return RecipePhoneWidget(
            recipeQuantityKey: recipeQuantityKey,
            recipeItems: chosenSizeRecipe,
            quantityControllers: recipeQuantityControllers,
            optionIndex: sizeIndex,
            onProductQuantityChanged: (recipeIndex, newQuantity) {
              if (recipeQuantityKey.currentState!.validate()) {
                chosenSizeRecipe[recipeIndex].quantity = int.parse(newQuantity);
                itemSizes[sizeIndex].costPrice =
                    calculateCostPriceForSize(itemSizes[sizeIndex]);
                sizeControllers[sizeIndex].values.elementAt(2).text =
                    itemSizes[sizeIndex].costPrice.toStringAsFixed(2);
              }
            },
            onChangeRecipeProductTap: (recipeIndex) async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers[recipeIndex] =
                    TextEditingController(text: '0');
                chosenSizeRecipe[recipeIndex] = RecipeItem(
                  productId: product.id,
                  productName: product.name,
                  costQuantity: product.costQuantity,
                  cost: product.cost,
                  quantity: 0,
                  measuringUnit: product.measuringUnit,
                );
              }
            },
            onDeleteRecipeProductTap: (recipeIndex) {
              chosenSizeRecipe.removeAt(recipeIndex);
              recipeQuantityControllers.removeAt(recipeIndex);
              itemSizes[sizeIndex].costPrice =
                  calculateCostPriceForSize(itemSizes[sizeIndex]);
              sizeControllers[sizeIndex].values.elementAt(2).text =
                  itemSizes[sizeIndex].costPrice.toStringAsFixed(2);
            },
            onAddRecipeProductTap: () async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers.add(TextEditingController(text: '0'));
                chosenSizeRecipe.add(
                  RecipeItem(
                    productId: product.id,
                    productName: product.name,
                    costQuantity: product.costQuantity,
                    cost: product.cost,
                    quantity: 0,
                    measuringUnit: product.measuringUnit,
                  ),
                );
              }
            },
          );
        },
      );
      Timer(const Duration(milliseconds: 200), () {
        recipeQuantityControllers.clear();
      });
    }
  }

  void initializeRecipe(RxList<RecipeItem> recipes) {
    recipeQuantityControllers.clear();
    for (RecipeItem recipe in recipes) {
      recipeQuantityControllers
          .add(TextEditingController(text: recipe.quantity.toString()));
    }
  }

  double calculateCostPriceForSize(ItemSizeModel sizeModel) {
    double sizeCost = 0.0;
    for (var recipeItem in sizeModel.recipe) {
      sizeCost +=
          (recipeItem.cost / recipeItem.costQuantity) * recipeItem.quantity;
    }

    return sizeCost;
  }

  void onEditOptionValueRecipeTap(
      bool isPhone, int optionIndex, int valueIndex) async {
    final chosenOptionRecipe = options[optionIndex].value[valueIndex].recipe;
    initializeRecipe(chosenOptionRecipe);
    if (isPhone) {
      await showFlexibleBottomSheet(
        bottomSheetColor: Colors.transparent,
        minHeight: 0,
        initHeight: 0.75,
        maxHeight: 1,
        anchors: [0, 0.75, 1],
        isSafeArea: true,
        context: Get.context!,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return RecipePhoneWidgetPhone(
            recipeQuantityKey: recipeQuantityKey,
            recipeItems: chosenOptionRecipe,
            scrollController: scrollController,
            quantityControllers: recipeQuantityControllers,
            optionIndex: optionIndex,
            onProductQuantityChanged: (recipeIndex, newQuantity) {
              if (recipeQuantityKey.currentState!.validate()) {
                chosenOptionRecipe[recipeIndex].quantity =
                    int.parse(newQuantity);
              }
            },
            onChangeRecipeProductTap: (recipeIndex) async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers[recipeIndex] =
                    TextEditingController(text: '0');
                chosenOptionRecipe[recipeIndex] = RecipeItem(
                  productId: product.id,
                  productName: product.name,
                  costQuantity: product.costQuantity,
                  cost: product.cost,
                  quantity: 0,
                  measuringUnit: product.measuringUnit,
                );
              }
            },
            onDeleteRecipeProductTap: (recipeIndex) {
              chosenOptionRecipe.removeAt(recipeIndex);
              recipeQuantityControllers.removeAt(recipeIndex);
            },
            onAddRecipeProductTap: () async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers.add(TextEditingController(text: '0'));
                chosenOptionRecipe.add(
                  RecipeItem(
                    productId: product.id,
                    productName: product.name,
                    costQuantity: product.costQuantity,
                    cost: product.cost,
                    quantity: 0,
                    measuringUnit: product.measuringUnit,
                  ),
                );
              }
            },
          );
        },
      );
      Timer(const Duration(milliseconds: 200), () {
        recipeQuantityControllers.clear();
      });
    } else {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return RecipePhoneWidget(
            recipeQuantityKey: recipeQuantityKey,
            recipeItems: chosenOptionRecipe,
            quantityControllers: recipeQuantityControllers,
            optionIndex: optionIndex,
            onProductQuantityChanged: (recipeIndex, newQuantity) {
              if (recipeQuantityKey.currentState!.validate()) {
                chosenOptionRecipe[recipeIndex].quantity =
                    int.parse(newQuantity);
              }
            },
            onChangeRecipeProductTap: (recipeIndex) async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers[recipeIndex] =
                    TextEditingController(text: '0');
                chosenOptionRecipe[recipeIndex] = RecipeItem(
                  productId: product.id,
                  productName: product.name,
                  costQuantity: product.costQuantity,
                  cost: product.cost,
                  quantity: 0,
                  measuringUnit: product.measuringUnit,
                );
              }
            },
            onDeleteRecipeProductTap: (recipeIndex) {
              chosenOptionRecipe.removeAt(recipeIndex);
              recipeQuantityControllers.removeAt(recipeIndex);
            },
            onAddRecipeProductTap: () async {
              final result = await Get.to(() => const ChooseRecipeProduct(),
                  transition: getPageTransition());
              if (result != null) {
                final product = result as ProductModel;
                recipeQuantityControllers.add(TextEditingController(text: '0'));
                chosenOptionRecipe.add(
                  RecipeItem(
                    productId: product.id,
                    productName: product.name,
                    costQuantity: product.costQuantity,
                    cost: product.cost,
                    quantity: 0,
                    measuringUnit: product.measuringUnit,
                  ),
                );
              }
            },
          );
        },
      );
      Timer(const Duration(milliseconds: 200), () {
        recipeQuantityControllers.clear();
      });
    }
  }

  void updateOptionValueRecipe(
      int optionIndex, int valueIndex, RxList<RecipeItem> newValue) {
    options[optionIndex].value[valueIndex].recipe = newValue;
    update();
  }

  void deleteOptionValue(int optionIndex, int valueIndex) {
    if (options[optionIndex].value.length > 1) {
      optionValueControllers[optionIndex][valueIndex].dispose();
      optionValueControllers[optionIndex].removeAt(valueIndex);
      options[optionIndex].value.removeAt(valueIndex);
      update();
    } else {
      showSnackBar(
        text: 'mustHaveOneOptionValue'.tr,
        snackBarType: SnackBarType.warning,
      );
    }
  }

  void deleteOption(int optionIndex) {
    optionKeyControllers[optionIndex].dispose();
    for (var controller in optionValueControllers[optionIndex]) {
      controller.dispose();
    }

    optionValueControllers.removeAt(optionIndex);
    optionKeyControllers.removeAt(optionIndex);
    options.removeAt(optionIndex);
    update();
  }

  void addSugarLevel() {
    itemSugarLevels.add('${'newSugarLevel'.tr} ${itemSugarLevels.length + 1}');
  }

  void updateSugarLevel(int index, String newLevel) {
    if (index >= 0 && index < itemSugarLevels.length) {
      itemSugarLevels.removeAt(index);
      itemSugarLevels.insert(index, newLevel);
    }
  }

  void deleteSugarLevel(int index) {
    if (index >= 0 && index < itemSugarLevels.length) {
      itemSugarLevels.removeAt(index);
      sugarLevelControllers.removeAt(index);
    }
  }

  @override
  void onClose() {
    for (var controller in sugarLevelControllers) {
      controller.dispose();
    }
    for (var controller in optionKeyControllers) {
      controller.dispose();
    }

    for (var controllers in optionValueControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    for (var map in sizeControllers) {
      for (var controller in map.values) {
        controller.dispose();
      }
    }
    itemRefreshController.dispose();
    super.onClose();
  }
}
