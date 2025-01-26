import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../general/general_functions.dart';
import 'category_item.dart';

class CategoryMenu extends StatelessWidget {
  const CategoryMenu(
      {super.key,
      required this.categories,
      required this.selectedCategory,
      required this.onSelect});
  final RxList<CategoryModel> categories;
  final int selectedCategory;
  final Function(int) onSelect;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 40,
        child: StretchingOverscrollIndicator(
          axisDirection:
              isLangEnglish() ? AxisDirection.right : AxisDirection.left,
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryItem(
                  icon: categoriesIconMap[categories[index].iconName] ??
                      Icons.local_drink,
                  categoryTitle: categories[index].name,
                  isSelected: index == selectedCategory,
                  onSelect: () => onSelect(index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
