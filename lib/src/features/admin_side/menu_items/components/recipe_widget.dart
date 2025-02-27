import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';

class RecipePhoneWidget extends StatelessWidget {
  const RecipePhoneWidget({
    super.key,
    required this.recipeItems,
    required this.quantityControllers,
    required this.onChangeRecipeProductTap,
    required this.onAddRecipeProductTap,
    required this.onDeleteRecipeProductTap,
    required this.optionIndex,
    required this.recipeQuantityKey,
    required this.onProductQuantityChanged,
  });

  final RxList<RecipeItem> recipeItems;
  final List<TextEditingController> quantityControllers;
  final Function(int, String) onProductQuantityChanged;
  final VoidCallback onAddRecipeProductTap;
  final Function(int) onChangeRecipeProductTap;
  final Function(int) onDeleteRecipeProductTap;
  final int optionIndex;
  final GlobalKey<FormState> recipeQuantityKey;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'recipeDetails'.tr,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Obx(
                            () => recipeItems.isEmpty
                                ? const SingleChildScrollView(
                                    child: NoRecipeFound(),
                                  )
                                : StretchingOverscrollIndicator(
                                    axisDirection: AxisDirection.down,
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: recipeQuantityKey,
                                        child: Column(
                                          children: recipeItems
                                              .asMap()
                                              .entries
                                              .map((recipeEntry) {
                                            final recipeIndex = recipeEntry.key;
                                            final recipeItem =
                                                recipeEntry.value;
                                            final quantityController =
                                                quantityControllers[
                                                    recipeIndex];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 120),
                                                    child: Text(
                                                      recipeItem.productName,
                                                      style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        color: Colors.black87,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      validator:
                                                          validateNumberIsInt,
                                                      controller:
                                                          quantityController,
                                                      onChanged: (newValue) =>
                                                          onProductQuantityChanged(
                                                        recipeIndex,
                                                        newValue.trim(),
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'quantity'.tr,
                                                        border:
                                                            const UnderlineInputBorder(),
                                                        labelStyle:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .black),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        isDense: true,
                                                      ),
                                                      cursorColor: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    recipeItem
                                                        .measuringUnit.name.tr,
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      color: Colors.black87,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.change_circle,
                                                        color: Colors.blue),
                                                    onPressed: () =>
                                                        onChangeRecipeProductTap(
                                                            recipeIndex),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        onDeleteRecipeProductTap(
                                                            recipeIndex),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: IconTextElevatedButton(
                                  buttonColor: Colors.grey.shade200,
                                  textColor: Colors.black,
                                  borderRadius: 15,
                                  fontSize: 16,
                                  iconSize: 20,
                                  elevation: 0,
                                  icon: Icons.add_rounded,
                                  iconColor: Colors.black,
                                  enabled: true,
                                  text: 'addProduct'.tr,
                                  onClick: onAddRecipeProductTap,
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
                                  iconSize: 24,
                                  elevation: 0,
                                  icon: Icons.save_rounded,
                                  iconColor: Colors.white,
                                  enabled: true,
                                  text: 'saveRecipe'.tr,
                                  onClick: () {
                                    FocusScope.of(context).unfocus();
                                    Get.back();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

class NoRecipeFound extends StatelessWidget {
  const NoRecipeFound({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          kEmptyCoffeeCupAnim,
          fit: BoxFit.contain,
          height: screenHeight * 0.2,
        ),
        AutoSizeText(
          'noRecipeTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noRecipeBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }
}
