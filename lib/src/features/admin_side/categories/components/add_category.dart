import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';
import '../../../cashier_side/orders/components/models.dart';

class AddCategory extends StatelessWidget {
  const AddCategory({
    super.key,
    required this.categoryNameTextController,
    required this.onAddTap,
    required this.formKey,
    required this.selectedCategoryIconName,
  });

  final TextEditingController categoryNameTextController;
  final RxString selectedCategoryIconName;
  final VoidCallback onAddTap;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'categoryDetails'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
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
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              items: categoriesIconMap.entries.map((entry) {
                                final String category = entry.key;
                                final IconData icon = entry.value;

                                return DropdownMenuItem<String>(
                                  value: category,
                                  child:
                                      Icon(icon, size: 24, color: Colors.black),
                                );
                              }).toList(),
                              value: selectedCategoryIconName.value,
                              onChanged: (value) {
                                if (value != null) {
                                  selectedCategoryIconName.value = value;
                                }
                              },
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: 65,
                              ),
                              buttonStyleData: ButtonStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                height: 40,
                                width: 40,
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              controller: categoryNameTextController,
                              keyboardType: TextInputType.name,
                              cursorColor: Colors.black,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'enterCategoryName'.tr,
                              ),
                              validator: textNotEmpty,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
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
                        text: 'addCategory'.tr,
                        onClick: onAddTap,
                      ),
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
}
