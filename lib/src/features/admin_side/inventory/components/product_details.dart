import 'package:cortadoeg/src/features/admin_side/inventory/components/models.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../controllers/inventory_screen_controller.dart';

class ManageProductDetails extends StatelessWidget {
  const ManageProductDetails({
    super.key,
    required this.controller,
    required this.edit,
    required this.productIndex,
  });

  final InventoryScreenController controller;
  final bool edit;
  final int productIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'productDetails'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StretchingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Form(
                                  key: controller.formKey,
                                  child: Column(
                                    children: [
                                      _buildTextField(
                                        controller:
                                            controller.productNameController,
                                        label: 'productName'.tr,
                                        keyboardType: TextInputType.name,
                                        validator: textNotEmpty,
                                      ),
                                      const SizedBox(height: 10),
                                      _buildTextField(
                                        controller: controller.costController,
                                        label: 'cost'.tr,
                                        keyboardType: TextInputType.number,
                                        validator: validateNumberIsDouble,
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(
                                        () => _buildTextField(
                                          controller:
                                              controller.costQuantityController,
                                          label: 'costQuantity'.trParams({
                                            'measuringUnit': controller
                                                .selectedMeasuringUnit
                                                .value
                                                .name
                                                .tr
                                          }),
                                          keyboardType: TextInputType.number,
                                          validator: validateNumberIsInt,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Obx(
                                        () => _buildTextField(
                                          controller: controller
                                              .availableQuantityController,
                                          label: 'availableQuantity'.trParams({
                                            'measuringUnit': controller
                                                .selectedMeasuringUnit
                                                .value
                                                .name
                                                .tr
                                          }),
                                          keyboardType: TextInputType.number,
                                          validator: validateNumberIsInt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'measuringUnit'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: Obx(
                                        () => DropdownButtonHideUnderline(
                                          child: DropdownButton2<MeasuringUnit>(
                                            isExpanded: true,
                                            hint: Text(
                                              'selectUnit'.tr,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            items: MeasuringUnit.values
                                                .map((mUnit) {
                                              return DropdownMenuItem<
                                                  MeasuringUnit>(
                                                value: mUnit,
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 120),
                                                  child: Text(
                                                    mUnit.name.tr,
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            value: controller
                                                .selectedMeasuringUnit.value,
                                            onChanged: (value) {
                                              if (value != null) {
                                                controller.selectedMeasuringUnit
                                                    .value = value;
                                              }
                                            },
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              width: 100,
                                            ),
                                            buttonStyleData: ButtonStyleData(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              height: 50,
                                              width: 100,
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              height: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'productIcon'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 90,
                                      child: Obx(
                                        () => DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: Text(
                                              'selectCategoryIcon'.tr,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            items: productsIconMap.entries
                                                .map((entry) {
                                              final String category = entry.key;
                                              final IconData icon = entry.value;

                                              return DropdownMenuItem<String>(
                                                value: category,
                                                child: Icon(icon,
                                                    size: 24,
                                                    color: Colors.black),
                                              );
                                            }).toList(),
                                            value: controller
                                                .selectedProductIconName.value,
                                            onChanged: (value) {
                                              if (value != null) {
                                                controller
                                                    .selectedProductIconName
                                                    .value = value;
                                              }
                                            },
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              width: 65,
                                            ),
                                            buttonStyleData: ButtonStyleData(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              height: 40,
                                              width: 40,
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              height: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      edit
                          ? Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 55,
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
                                      onClick: () => controller.onDeleteTap(
                                          index: productIndex),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 55,
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
                                      onClick: () => controller.onSaveTap(
                                          index: productIndex),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 55,
                              child: IconTextElevatedButton(
                                buttonColor: Colors.black,
                                textColor: Colors.white,
                                borderRadius: 15,
                                fontSize: 18,
                                iconSize: 22,
                                elevation: 0,
                                icon: Icons.add_rounded,
                                iconColor: Colors.white,
                                enabled: true,
                                text: 'addProduct'.tr,
                                onClick: () => controller.addItem(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ]),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const UnderlineInputBorder(),
        labelStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        isDense: true,
      ),
      validator: validator,
      cursorColor: Colors.black,
    );
  }
}
