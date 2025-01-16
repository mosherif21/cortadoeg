import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../general/app_init.dart';

class AdminMainScreenController extends GetxController {
  static AdminMainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final navBarIndex = 0.obs;
  final RxBool navBarExtended = false.obs;
  final firestore = FirebaseFirestore.instance;
  final notificationsCount = 0.obs;
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      notificationCountStreamSubscription;

  @override
  void onInit() async {
    barController = SidebarXController(selectedIndex: 0, extended: true);
    pageController = PageController(initialPage: 0, keepPage: true);
    homeScaffoldKey = GlobalKey<ScaffoldState>();
    super.onInit();
  }

  @override
  void onReady() {
    barController.addListener(() {
      navBarExtended.value = barController.extended;
      final selectedNavIndex = barController.selectedIndex;
      navBarIndex.value = selectedNavIndex;
      pageController.jumpToPage(selectedNavIndex);
    });
    handleNotificationsPermission();
    listenForNotificationCount();
    super.onReady();
  }

  void onDrawerOpen() {
    barController.setExtended(true);
    homeScaffoldKey.currentState?.openDrawer();
  }

  void listenForNotificationCount() {
    try {
      final userId = AuthenticationRepository.instance.employeeInfo!.id;
      notificationCountStreamSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          notificationsCount.value = snapshot.data()!['unseenCount'] as int;
        } else {
          notificationsCount.value = 0;
        }
      });
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
  }

  String getPageTitle(int navBarIndex) {
    switch (navBarIndex) {
      case 0:
        return 'reports'.tr;
      case 1:
        return 'custodyShifts'.tr;
      case 2:
        return 'tables'.tr;
      case 3:
        return 'menuItems'.tr;
      case 4:
        return 'categories'.tr;
      case 5:
        return 'inventory'.tr;
      case 6:
        return 'customers'.tr;
      case 7:
        return 'employees'.tr;
      case 8:
        return 'passcodes'.tr;
      case 9:
        return 'account'.tr;
      default:
        return 'reports'.tr;
    }
  }

  @override
  void onClose() async {
    pageController.dispose();
    barController.dispose();
    notificationCountStreamSubscription?.cancel();
    super.onClose();
  }
}
