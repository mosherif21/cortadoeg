import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../authentication/models.dart';
import '../../../../constants/enums.dart';
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
    final hasViewSalesPermission = hasPermission(
        AuthenticationRepository.instance.employeeInfo!,
        UserPermission.viewSalesReports);
    if (!hasViewSalesPermission) {
      navBarIndex.value = 9;
      pageController.jumpToPage(navBarIndex.value);
      barController.selectIndex(9);
    }
    barController.addListener(() {
      navBarExtended.value = barController.extended;
      final selectedNavIndex = barController.selectedIndex;
      bool hasPermissionForPage = false;
      switch (selectedNavIndex) {
        case 0:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.viewSalesReports);
          break;
        case 1:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.viewCustodyReports);
          break;
        case 2:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageTablesAvailability);
          break;
        case 3:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageItems);
          break;
        case 4:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageItems);
          break;
        case 5:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageInventory);
          break;
        case 6:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageCustomers);
          break;
        case 7:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.manageEmployees);
          break;
        case 8:
          hasPermissionForPage = hasPermission(
              AuthenticationRepository.instance.employeeInfo!,
              UserPermission.managePasscodes);
          break;
        case 9:
          hasPermissionForPage = true;
          break;
        default:
          hasPermissionForPage = false;
      }
      if (hasPermissionForPage) {
        navBarIndex.value = barController.selectedIndex;
        pageController.jumpToPage(barController.selectedIndex);
      } else {
        barController.selectIndex(navBarIndex.value);
        showSnackBar(
          text: 'functionNotAllowed'.tr,
          snackBarType: SnackBarType.error,
        );
      }
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
        return 'salesOverview'.tr;
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
