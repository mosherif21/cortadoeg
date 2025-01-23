import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/orders/components/models.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../controllers/categories_screen_controller.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final CategoryScreenController controller =
        Get.put(CategoryScreenController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'categories'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
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
                  controller.addCategoryTap(isPhone: screenType.isPhone),
            )
          : null,
      body: Column(
        children: [
          screenType.isPhone
              ? AnimSearchAppBar(
                  keyboardType: TextInputType.text,
                  cancelButtonTextStyle: const TextStyle(color: Colors.black87),
                  cancelButtonText: 'cancel'.tr,
                  hintText: 'searchCategoriesHint'.tr,
                  hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                  onChanged: controller.onCategoriesSearch,
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
                        hintText: 'searchCategoriesHint'.tr,
                        hintStyle: const TextStyle(fontWeight: FontWeight.w600),
                        onChanged: controller.onCategoriesSearch,
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
                        text: 'addCategory'.tr,
                        onClick: () => controller.addCategoryTap(
                            isPhone: screenType.isPhone),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
          Expanded(
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
                  controller: controller.categoryRefreshController,
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
                  child: !controller.loadingCategories.value &&
                          controller.categories.isEmpty
                      ? const SingleChildScrollView(child: NoCategoriesFound())
                      : screenType.isPhone
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return controller.loadingCategories.value
                                    ? const LoadingCategoryCard()
                                    : CategoryCard(
                                        category: controller.categories[index],
                                        onTap: () => controller.onCategoryTap(
                                            index: index,
                                            isPhone: screenType.isPhone),
                                      );
                              },
                              itemCount: controller.loadingCategories.value
                                  ? 10
                                  : controller.categories.length,
                            )
                          : AnimationLimiter(
                              child: GridView.count(
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                physics: const ScrollPhysics(),
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                children: List.generate(
                                  controller.loadingCategories.value
                                      ? 20
                                      : controller.categories.length,
                                  (int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      columnCount: 4,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: controller
                                                  .loadingCategories.value
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .shade200, //New
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade200,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              height: 80,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            Container(
                                                              width: 150,
                                                              height: 35,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .shade200, //New
                                                          blurRadius: 10,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Colors.white,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        splashFactory:
                                                            InkSparkle
                                                                .splashFactory,
                                                        onTap: () => controller
                                                            .onCategoryTap(
                                                                index: index,
                                                                isPhone:
                                                                    screenType
                                                                        .isPhone),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                categoriesIconMap[
                                                                    controller
                                                                        .categories[
                                                                            index]
                                                                        .iconName],
                                                                size: 55,
                                                              ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              Text(
                                                                controller
                                                                    .categories[
                                                                        index]
                                                                    .name,
                                                                style:
                                                                    const TextStyle(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, //New
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            splashFactory: InkSparkle.splashFactory,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    categoriesIconMap[category.iconName],
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    category.name,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoCategoriesFound extends StatelessWidget {
  const NoCategoriesFound({super.key});

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
          'noCategoriesFoundTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noCategoriesFoundBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }
}

class LoadingCategoryCard extends StatelessWidget {
  const LoadingCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300, //New
              blurRadius: 5.0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.black,
                ),
                const SizedBox(width: 16),
                Container(
                  width: 150,
                  height: 35,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
