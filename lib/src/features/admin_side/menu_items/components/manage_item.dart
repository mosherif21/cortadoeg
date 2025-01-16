import 'package:cross_file_image/cross_file_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../../../cashier_side/orders/components/models.dart';
import '../controllers/menu_items_screen_controller.dart';

class ManageItemDetails extends StatelessWidget {
  const ManageItemDetails({
    super.key,
    required this.controller,
    required this.edit,
    required this.itemIndex,
    this.imageUrl,
  });

  final ItemsScreenController controller;
  final bool edit;
  final int itemIndex;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => controller.isItemImageLoaded.value
                                  ? Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Material(
                                          elevation: 5,
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(110),
                                          child: CircleAvatar(
                                            radius: 110,
                                            backgroundColor: Colors.white,
                                            backgroundImage: controller
                                                    .isItemImageChanged.value
                                                ? XFileImage(
                                                    controller.itemImage.value!)
                                                : controller.itemMemoryImage
                                                        .value ??
                                                    const AssetImage(
                                                      kLogoImage,
                                                    ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 5,
                                          right: isLangEnglish() ? 40 : null,
                                          left: isLangEnglish() ? null : 40,
                                          child: Material(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.black,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              splashFactory:
                                                  InkSparkle.splashFactory,
                                              onTap: () =>
                                                  controller.onEditItemImageTap(
                                                isPhone: false,
                                                itemId: controller
                                                        .items[itemIndex]
                                                        .imageUrl ??
                                                    '',
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: const CircleAvatar(
                                        radius: 110,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),
                            _buildTitleSection(),
                            const SizedBox(height: 20),
                            _buildCategorySelection(
                              'itemCategory'.tr,
                              context,
                              controller.selectedCategoryIndex,
                              controller.categories,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              'name'.tr,
                              controller.itemNameTextController,
                              'enterItemName'.tr,
                              TextInputAction.next,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              'description'.tr,
                              controller.itemDescriptionTextController,
                              'enterItemDescription'.tr,
                              TextInputAction.done,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right Section (Scrollable)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: StretchingOverscrollIndicator(
                            axisDirection: AxisDirection.down,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => _buildSizesManageableSection(
                                      'sizes'.tr,
                                      'addSize'.tr,
                                      false,
                                      controller.itemSizes,
                                      onAdd: controller.addSize,
                                      onEdit: controller.onEditSizeRecipeTap,
                                      onDelete: controller.deleteSize,
                                      buildItem: (size, index) =>
                                          _buildSizeFields(size, index),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Obx(
                                    () => _buildOptionsManageableSection(
                                      'options'.tr,
                                      'addOption'.tr,
                                      controller.options,
                                      onAdd: controller.addOptionKey,
                                      buildItem: (entry, index) =>
                                          _buildOptionFields(entry, index),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Obx(
                                    () => _buildManageableSection(
                                      'sugarLevels'.tr,
                                      'addSugarLevel'.tr,
                                      controller.itemSugarLevels,
                                      onAdd: controller.addSugarLevel,
                                      onDelete: controller.deleteSugarLevel,
                                      buildItem: (level, index) =>
                                          _buildSugarLevelField(level, index),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: _buildActionButtons(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: isLangEnglish() ? 5 : null,
              left: isLangEnglish() ? null : 5,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return TextField(
      enabled: false,
      controller: controller.itemNameTextController,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller,
      String hint, TextInputAction inputAction,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            textInputAction: inputAction,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            controller: controller,
            keyboardType: TextInputType.name,
            cursorColor: Colors.black,
            maxLines: maxLines,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[200],
              hintText: hint,
            ),
            validator: textNotEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(String title, BuildContext context,
      RxInt selectedCategoryIndex, List<CategoryModel> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Obx(
          () => DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              isExpanded: true,
              hint: Text(
                'selectCategoryIcon'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).hintColor,
                ),
              ),
              items: categories.map((category) {
                final String categoryName = category.name;
                final IconData icon = categoriesIconMap[category.iconName]!;
                return DropdownMenuItem<int>(
                  value: categories.indexOf(category),
                  child: Row(
                    children: [
                      Icon(icon, size: 24, color: Colors.black),
                      const SizedBox(width: 10),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              value: selectedCategoryIndex.value,
              onChanged: (value) {
                if (value != null) {
                  if (value == 0) {
                    showSnackBar(
                      text: 'errorChosenValue'.tr,
                      snackBarType: SnackBarType.warning,
                    );
                  } else {
                    selectedCategoryIndex.value = value;
                  }
                }
              },
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 200,
              ),
              buttonStyleData: ButtonStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                width: 200,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizesManageableSection<T>(
    String title,
    String addButtonTitle,
    bool isPhone,
    List<T> items, {
    required VoidCallback onAdd,
    required Function(bool, int) onEdit,
    required Function(int) onDelete,
    required Widget Function(T, int) buildItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Row(
            children: [
              Expanded(child: buildItem(item, index)),
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.menu_book_rounded, color: Colors.blue),
                    onPressed: () => onEdit(isPhone, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red),
                    onPressed: () => onDelete(index),
                  ),
                ],
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          width: 180,
          child: IconTextElevatedButton(
            buttonColor: Colors.grey.shade200,
            textColor: Colors.black87,
            borderRadius: 10,
            elevation: 0,
            icon: Icons.add_rounded,
            iconColor: Colors.black87,
            text: addButtonTitle,
            onClick: onAdd,
          ),
        ),
      ],
    );
  }

  Widget _buildManageableSection<T>(
    String title,
    String addButtonTitle,
    List<T> items, {
    required VoidCallback onAdd,
    required Function(int) onDelete,
    required Widget Function(T, int) buildItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Row(
            children: [
              Expanded(child: buildItem(item, index)),
              IconButton(
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () => onDelete(index),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          width: 180,
          child: IconTextElevatedButton(
            buttonColor: Colors.grey.shade200,
            textColor: Colors.black87,
            borderRadius: 10,
            elevation: 0,
            icon: Icons.add_rounded,
            iconColor: Colors.black87,
            text: addButtonTitle,
            onClick: onAdd,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsManageableSection<T>(
    String title,
    String addButtonTitle,
    List<T> items, {
    required VoidCallback onAdd,
    required Widget Function(T, int) buildItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return buildItem(item, index);
        }),
        const SizedBox(height: 12),
        SizedBox(
          width: 180,
          child: IconTextElevatedButton(
            buttonColor: Colors.grey.shade200,
            textColor: Colors.black87,
            borderRadius: 10,
            elevation: 0,
            icon: Icons.add_rounded,
            iconColor: Colors.black87,
            text: addButtonTitle,
            onClick: onAdd,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeFields(ItemSizeModel size, int index) {
    while (controller.sizeControllers.length <= index) {
      controller.sizeControllers.add({
        'name': TextEditingController(text: size.name),
        'price': TextEditingController(text: size.price.toStringAsFixed(2)),
        'costPrice':
            TextEditingController(text: size.costPrice.toStringAsFixed(2)),
      });
    }

    final controllers = controller.sizeControllers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controllers['name'],
              onChanged: (value) => size.name = value.trim(),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'sizeName'.tr,
                border: const UnderlineInputBorder(),
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                isDense: true,
              ),
              cursorColor: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controllers['price'],
              onChanged: (value) => size.price = double.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'price'.tr,
                border: const UnderlineInputBorder(),
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                isDense: true,
              ),
              cursorColor: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controllers['costPrice'],
              onChanged: (value) =>
                  size.costPrice = double.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'costPrice'.tr,
                border: const UnderlineInputBorder(),
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                isDense: true,
              ),
              cursorColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionFields(
      MapEntry<String, RxList<OptionValue>> entry, int index) {
    while (controller.optionValueControllers.length <= index) {
      controller.optionValueControllers.add([]);
      controller.optionKeyControllers
          .add(TextEditingController(text: entry.key));
    }
    final valueControllers = controller.optionValueControllers[index];
    final optionKeyController = controller.optionKeyControllers[index];
    for (int valueIndex = 0; valueIndex < entry.value.length; valueIndex++) {
      if (valueControllers.length <= valueIndex) {
        valueControllers
            .add(TextEditingController(text: entry.value[valueIndex].name));
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: optionKeyController,
            onChanged: (value) =>
                controller.updateOptionKey(index, value.trim()),
            decoration: InputDecoration(
              labelText: 'optionName'.tr,
              border: const UnderlineInputBorder(),
              labelStyle: const TextStyle(color: Colors.black),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              isDense: true,
            ),
            cursorColor: Colors.black,
          ),
          const SizedBox(height: 10),
          Obx(
            () => Column(
              children: entry.value.asMap().entries.map((valueEntry) {
                final valueIndex = valueEntry.key;
                final valueController = valueControllers[valueIndex];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: valueController,
                          onChanged: (newValue) =>
                              controller.updateOptionValueName(
                            index,
                            valueIndex,
                            newValue.trim(),
                          ),
                          decoration: InputDecoration(
                            labelText: 'value'.tr,
                            border: const UnderlineInputBorder(),
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            isDense: true,
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu_book_rounded,
                                color: Colors.blue),
                            onPressed: () =>
                                controller.onEditOptionValueRecipeTap(
                                    false, index, valueIndex),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                            onPressed: () =>
                                controller.deleteOptionValue(index, valueIndex),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 160,
                child: IconTextElevatedButton(
                  buttonColor: Colors.grey.shade200,
                  textColor: Colors.red,
                  borderRadius: 10,
                  elevation: 0,
                  icon: Icons.delete_outline_rounded,
                  iconColor: Colors.red,
                  text: 'deleteOption'.tr,
                  onClick: () => controller.deleteOption(index),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 160,
                child: IconTextElevatedButton(
                  buttonColor: Colors.grey.shade200,
                  textColor: Colors.green,
                  borderRadius: 10,
                  elevation: 0,
                  icon: Icons.add_rounded,
                  iconColor: Colors.green,
                  text: 'addValue'.tr,
                  onClick: () => controller.addOptionValue(index),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSugarLevelField(String level, int index) {
    if (controller.sugarLevelControllers.length <= index) {
      controller.sugarLevelControllers.add(TextEditingController(text: level));
    }

    final textController = controller.sugarLevelControllers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: textController,
        onChanged: (value) => controller.updateSugarLevel(index, value.trim()),
        decoration: InputDecoration(
          labelText: 'levelName'.tr,
          border: const UnderlineInputBorder(),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          isDense: true,
        ),
        cursorColor: Colors.black,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return edit
        ? Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: IconTextElevatedButton(
                    buttonColor: Colors.red,
                    textColor: Colors.white,
                    borderRadius: 15,
                    fontSize: 18,
                    iconSize: 22,
                    elevation: 0,
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.white,
                    enabled: true,
                    text: 'delete'.tr,
                    onClick: () => controller.onDeleteItemTap(itemIndex),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: IconTextElevatedButton(
                    buttonColor: Colors.black,
                    textColor: Colors.white,
                    borderRadius: 15,
                    fontSize: 18,
                    iconSize: 22,
                    elevation: 0,
                    icon: Icons.save,
                    iconColor: Colors.white,
                    enabled: true,
                    text: 'save'.tr,
                    onClick: () => controller.editItem(itemIndex: itemIndex),
                  ),
                ),
              ),
            ],
          )
        : SizedBox(
            height: 50,
            child: IconTextElevatedButton(
              buttonColor: Colors.black,
              textColor: Colors.white,
              borderRadius: 15,
              fontSize: 18,
              iconSize: 24,
              elevation: 0,
              icon: Icons.add_rounded,
              iconColor: Colors.white,
              enabled: true,
              text: 'addItem'.tr,
              onClick: controller.addItem,
            ),
          );
  }
}
