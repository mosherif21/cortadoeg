import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/menu_items/controllers/choose_recipe_controller.dart';
import 'package:cortadoeg/src/general/common_widgets/back_button.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../inventory/components/models.dart';

class ChooseRecipeProduct extends StatelessWidget {
  const ChooseRecipeProduct({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChooseRecipeController());
    final screenHeight = getScreenHeight(context);
    final screenType = GetScreenType(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          AnimSearchAppBar(
            keyboardType: TextInputType.text,
            cancelButtonTextStyle: const TextStyle(color: Colors.black87),
            cancelButtonText: 'cancel'.tr,
            hintText: 'searchProductsHint'.tr,
            onChanged: controller.onCustomerSearch,
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: const RegularBackButton(padding: 0),
              elevation: 0,
              title: Text(
                'chooseProduct'.tr,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
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
                  controller: controller.productsRefreshController,
                  onRefresh: () => controller.onRefresh(),
                  child: !controller.loadingProducts.value &&
                          controller.filteredProductsList.isEmpty
                      ? const SingleChildScrollView(child: NoProductsFound())
                      : screenType.isPhone
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return controller.loadingProducts.value
                                    ? const LoadingItemCard()
                                    : ProductCard(
                                        product: controller
                                            .filteredProductsList[index],
                                        onTap: () => controller.onProductTap(
                                            index: index),
                                      );
                              },
                              itemCount: controller.loadingProducts.value
                                  ? 10
                                  : controller.filteredProductsList.length,
                            )
                          : AnimationLimiter(
                              child: GridView.count(
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                physics: const ScrollPhysics(),
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                children: List.generate(
                                  controller.loadingProducts.value
                                      ? 20
                                      : controller.filteredProductsList.length,
                                  (int index) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      columnCount: 4,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: controller
                                                  .loadingProducts.value
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
                                                              .shade300, //New
                                                          blurRadius: 5.0,
                                                        )
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
                                                              .shade300, //New
                                                          blurRadius: 5.0,
                                                        )
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
                                                            .onProductTap(
                                                                index: index),
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
                                                                productsIconMap[
                                                                    controller
                                                                        .filteredProductsList[
                                                                            index]
                                                                        .iconName],
                                                                size: 55,
                                                              ),
                                                              const SizedBox(
                                                                  height: 16),
                                                              Text(
                                                                controller
                                                                    .filteredProductsList[
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300, //New
              blurRadius: 5.0,
            )
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
                    productsIconMap[product.iconName],
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    product.name,
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

class NoProductsFound extends StatelessWidget {
  const NoProductsFound({super.key});

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
          'noProductsFoundTitle'.tr,
          style: const TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          'noProductsFoundBody'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w500),
          maxLines: 2,
        ),
      ],
    );
  }
}

class LoadingItemCard extends StatelessWidget {
  const LoadingItemCard({super.key});

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
