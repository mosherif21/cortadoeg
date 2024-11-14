import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../components/cart_item_widget.dart';
import '../components/item_widget.dart';
import '../components/new_order_categories.dart';
import '../components/new_order_screen_appbar.dart';
import '../controllers/new_order_controller.dart';

class NewOrdersScreen extends StatelessWidget {
  const NewOrdersScreen(
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
      body: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
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
                            titleFontSize: 20,
                          ),
                          Obx(
                            () => CategoryMenu(
                              categories: controller.categories,
                              selectedCategory:
                                  controller.selectedCategory.value,
                              onSelect: controller.onCategorySelect,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Obx(
                            () => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: AnimationLimiter(
                                child: GridView.count(
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing:
                                      controller.orderItems.isEmpty ? 20 : 20,
                                  physics: const ScrollPhysics(),
                                  crossAxisCount:
                                      controller.orderItems.isEmpty ? 5 : 4,
                                  shrinkWrap: true,
                                  children: List.generate(
                                    controller.selectedItems.length,
                                    (int index) {
                                      return AnimationConfiguration
                                          .staggeredGrid(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        columnCount: 5,
                                        child: ScaleAnimation(
                                          child: FadeInAnimation(
                                            child: ItemCard(
                                              imageUrl: controller
                                                  .selectedItems[index]
                                                  .imageUrl,
                                              title: controller
                                                  .selectedItems[index].name,
                                              price: controller
                                                  .selectedItems[index]
                                                  .sizes[0]
                                                  .price,
                                              onSelected: () =>
                                                  controller.onItemSelected(
                                                      context, index),
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
            controller.orderItems.isNotEmpty
                ? Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200, //New
                            blurRadius: 5,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  'noCustomer'.tr,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                IconTextElevatedButton(
                                  buttonColor: Colors.grey.shade100,
                                  textColor: Colors.black87,
                                  borderRadius: 10,
                                  elevation: 0,
                                  icon: Icons.add_rounded,
                                  iconColor: Colors.black87,
                                  text: 'addCustomer'.tr,
                                  onClick: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const SectionDivider(),
                            const SizedBox(height: 5),
                            Expanded(
                              child: StretchingOverscrollIndicator(
                                axisDirection: AxisDirection.down,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: controller.orderItems.length,
                                  itemBuilder: (context, index) {
                                    return CartItemWidget(
                                      orderItemModel:
                                          controller.orderItems[index],
                                      onEditTap: () =>
                                          controller.onEditItem(index, context),
                                      onDeleteTap: () =>
                                          controller.onDeleteItem(index),
                                      index: index,
                                      onDismissed: () =>
                                          controller.onDeleteItem(index),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('subtotal'.tr),
                                      Text(
                                          '\$${controller.orderSubtotal.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('discountSales'.tr),
                                      Text(
                                          '-\$${controller.discountAmount.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('totalSalesTax'.tr),
                                      Text(
                                          '\$${controller.orderTax.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('total'.tr),
                                      Text(
                                          '\$${controller.orderTotal.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconTextElevatedButton(
                                  buttonColor: Colors.deepOrange,
                                  textColor: Colors.white,
                                  borderRadius: 10,
                                  elevation: 0,
                                  icon: Icons.pause,
                                  iconColor: Colors.white,
                                  text: 'holdCart'.tr,
                                  onClick: () {},
                                ),
                                IconTextElevatedButton(
                                  buttonColor: Colors.green,
                                  textColor: Colors.white,
                                  borderRadius: 10,
                                  elevation: 0,
                                  icon: Icons.payments_outlined,
                                  iconColor: Colors.white,
                                  text: 'charge'.trParams({
                                    'total':
                                        controller.orderTotal.toStringAsFixed(2)
                                  }),
                                  onClick: () {},
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
