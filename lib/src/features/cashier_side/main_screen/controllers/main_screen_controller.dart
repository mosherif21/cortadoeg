import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

class MainScreenController extends GetxController {
  static MainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final pagesTitle = 'activeOrders'.tr.obs;
  int navBarIndex = 0;

  @override
  void onInit() async {
    barController = SidebarXController(selectedIndex: 0, extended: false);
    pageController = PageController(initialPage: 0);
    homeScaffoldKey = GlobalKey<ScaffoldState>();
    super.onInit();
  }

  @override
  void onReady() {
    barController.addListener(() {
      navBarIndex = barController.selectedIndex;
      pageController.jumpToPage(barController.selectedIndex);
    });

    super.onReady();
  }

  @override
  void onClose() async {
    pageController.dispose();
    barController.dispose();
    super.onClose();
  }

  void onDrawerOpen() {
    barController.setExtended(true);
    homeScaffoldKey.currentState?.openDrawer();
  }
}
