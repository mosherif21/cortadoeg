import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../general/general_functions.dart';
import '../components/item_widget_phone.dart';
import '../components/new_order_categories_phone.dart';
import '../components/new_order_screen_appbar.dart';
import '../controllers/new_order_controller.dart';

class NewOrdersScreenPhone extends StatelessWidget {
  const NewOrdersScreenPhone(
      {super.key,
      required this.isTakeaway,
      this.tablesNo,
      required this.currentOrderId});

  final bool isTakeaway;
  final List<int>? tablesNo;
  final String currentOrderId;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(NewOrderController(
        isTakeaway: isTakeaway,
        currentOrderId: currentOrderId,
        tablesNo: tablesNo));
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: StretchingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          child: SingleChildScrollView(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    NewOrderScreenAppbar(
                      searchBarTextController:
                          controller.searchBarTextController,
                      isTakeaway: isTakeaway,
                      currentOrderId: currentOrderId,
                      tablesNo: tablesNo,
                      titleFontSize: 18,
                    ),
                    Obx(
                      () => CategoryMenuPhone(
                        categories: controller.categories,
                        selectedCategory: controller.selectedCategory.value,
                        onSelect: controller.onCategorySelect,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimationLimiter(
                          child: GridView.count(
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            physics: const ScrollPhysics(),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            children: List.generate(
                              controller.selectedItems.length,
                              (int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 300),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: ItemCardPhone(
                                        imageUrl: kCoffeeCup2Image,
                                        title: controller
                                            .selectedItems[index].name,
                                        price: controller.selectedItems[index]
                                            .sizes[0].price,
                                        onSelected: () {},
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
