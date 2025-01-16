import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/menu_items/controllers/menu_items_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/item_widget.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/new_order_categories.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/new_order_categories_phone.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/orders/components/item_widget_phone.dart';
import '../../../cashier_side/orders/screens/order_screen_phone.dart';
import '../../admin_main_screen/components/main_appbar.dart';

class MeniItemsScreen extends StatelessWidget {
  const MeniItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(ItemsScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'menuItems'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      floatingActionButton: screenType.isPhone
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              tooltip: 'addCategory'.tr,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () =>
                  controller.addItemTap(isPhone: screenType.isPhone),
            )
          : null,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          screenType.isPhone
              ? AnimSearchAppBar(
                  keyboardType: TextInputType.text,
                  cancelButtonTextStyle: const TextStyle(color: Colors.black87),
                  cancelButtonText: 'cancel'.tr,
                  hintText: 'searchItemsHint'.tr,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                  onChanged: controller.onItemsSearch,
                  backgroundColor: Colors.white,
                  appBar: const SizedBox.shrink(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AnimSearchAppBar(
                        keyboardType: TextInputType.text,
                        cancelButtonTextStyle:
                            const TextStyle(color: Colors.black87),
                        cancelButtonText: 'cancel'.tr,
                        hintText: 'searchItemsHint'.tr,
                        hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                        onChanged: controller.onItemsSearch,
                        backgroundColor: Colors.white,
                        appBar: const SizedBox.shrink(),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: IconTextElevatedButton(
                        buttonColor: Colors.black,
                        textColor: Colors.white,
                        borderRadius: 25,
                        fontSize: 16,
                        elevation: 0,
                        icon: Icons.add_rounded,
                        iconColor: Colors.white,
                        text: 'addItem'.tr,
                        onClick: () =>
                            controller.addItemTap(isPhone: screenType.isPhone),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
          Obx(
            () => controller.loadingCategories.value
                ? screenType.isPhone
                    ? const LoadingCategoriesPhone()
                    : const LoadingCategories()
                : screenType.isPhone
                    ? CategoryMenuPhone(
                        categories: controller.categories,
                        selectedCategory: controller.categoryFilterIndex.value,
                        onSelect: controller.onCategorySelect,
                      )
                    : CategoryMenu(
                        categories: controller.categories,
                        selectedCategory: controller.categoryFilterIndex.value,
                        onSelect: controller.onCategorySelect,
                      ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: Obx(
                  () => SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: ClassicHeader(
                      completeDuration: const Duration(milliseconds: 0),
                      releaseText: 'releaseToRefresh'.tr,
                      refreshingText: 'refreshing'.tr,
                      idleText: 'pullToRefresh'.tr,
                      completeText: 'refreshCompleted'.tr,
                      iconPos: isLangEnglish()
                          ? IconPosition.left
                          : IconPosition.right,
                    ),
                    controller: controller.itemRefreshController,
                    onRefresh: () => controller.onRefresh(),
                    onLoading: () => controller.onLoadMore(),
                    footer: ClassicFooter(
                      completeDuration: const Duration(milliseconds: 0),
                      canLoadingText: 'releaseToLoad'.tr,
                      noDataText: 'noMoreCategories'.tr,
                      idleText: 'pullToLoad'.tr,
                      loadingText: 'loading'.tr,
                      iconPos: isLangEnglish()
                          ? IconPosition.left
                          : IconPosition.right,
                    ),
                    child: !controller.loadingItems.value &&
                            controller.items.isEmpty
                        ? const SingleChildScrollView(child: NoItemsFound())
                        : Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 6,
                              right: 6,
                            ),
                            child: AnimationLimiter(
                              child: GridView.count(
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                physics: const ScrollPhysics(),
                                crossAxisCount: screenType.isPhone ? 2 : 4,
                                shrinkWrap: true,
                                children: List.generate(
                                  controller.loadingItems.value
                                      ? screenType.isPhone
                                          ? 10
                                          : 20
                                      : controller.items.length,
                                  (int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      columnCount: screenType.isPhone ? 2 : 4,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: controller.loadingItems.value
                                              ? screenType.isPhone
                                                  ? const LoadingItemPhone()
                                                  : const LoadingItem()
                                              : screenType.isPhone
                                                  ? ItemCardPhone(
                                                      imageUrl: controller
                                                          .items[index]
                                                          .imageUrl,
                                                      title: controller
                                                          .items[index].name,
                                                      price: controller
                                                          .items[index]
                                                          .sizes[0]
                                                          .price,
                                                      onSelected: () =>
                                                          controller.onItemTap(
                                                        isPhone:
                                                            screenType.isPhone,
                                                        index: index,
                                                      ),
                                                    )
                                                  : ItemCard(
                                                      imageUrl: controller
                                                          .items[index]
                                                          .imageUrl,
                                                      title: controller
                                                          .items[index].name,
                                                      price: controller
                                                          .items[index]
                                                          .sizes[0]
                                                          .price,
                                                      onSelected: () =>
                                                          controller.onItemTap(
                                                        isPhone:
                                                            screenType.isPhone,
                                                        index: index,
                                                      ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  const NoItemsFound({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          kEmptyCoffeeCupAnim,
          fit: BoxFit.contain,
          height: screenHeight * 0.3,
        ),
        AutoSizeText(
          'noItemsFoundTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noItemsFoundBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }
}
