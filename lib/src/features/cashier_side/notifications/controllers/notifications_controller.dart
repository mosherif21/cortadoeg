import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/features/admin_side/admin_main_screen/controllers/admin_main_screen_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/main_screen/controllers/main_screen_controller.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/enums.dart';
import '../../../../general/general_functions.dart';
import '../components/notification_item.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final notificationList = <NotificationItem>[].obs;

  final notificationLoaded = false.obs;
  final notificationsRefreshController =
      RefreshController(initialRefresh: false);
  @override
  void onInit() async {
    //
    super.onInit();
  }

  @override
  void onReady() async {
    loadNotifications();
  }

  Future<List<NotificationItem>?> getNotifications() async {
    try {
      final employeeId = AuthenticationRepository.instance.employeeInfo!.id;
      final userNotificationRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc(employeeId);
      final notificationSnapshot = await userNotificationRef.get();
      final notificationList = <NotificationItem>[];
      if (notificationSnapshot.exists) {
        final userNRef = userNotificationRef.collection('messages');
        await userNRef.get().then((notificationSnapshot) {
          for (var notificationDoc in notificationSnapshot.docs) {
            final notificationData = notificationDoc.data();
            notificationList.add(
              NotificationItem(
                title: notificationData['title'].toString(),
                body: notificationData['body'].toString(),
                timestamp: notificationData['timestamp'],
              ),
            );
          }
        });
        notificationList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      return notificationList;
    } on FirebaseException catch (error) {
      if (kDebugMode) AppInit.logger.e(error.toString());
    } catch (e) {
      if (kDebugMode) AppInit.logger.e(e.toString());
    }
    return null;
  }

  Future<void> resetNotificationCount() async {
    try {
      final employeeId = AuthenticationRepository.instance.employeeInfo!.id;
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(employeeId)
          .set({'unseenCount': 0});
    } on FirebaseException catch (error) {
      if (kDebugMode) print(error.toString());
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  void loadNotifications() async {
    final notifications = await getNotifications();
    if (notifications != null) {
      notificationList.value = notifications;
      notificationLoaded.value = true;
      if (Get.isRegistered<MainScreenController>()) {
        if (MainScreenController.instance.notificationsCount.value != 0) {
          await resetNotificationCount();
        }
      } else if (Get.isRegistered<AdminMainScreenController>()) {
        if (AdminMainScreenController.instance.notificationsCount.value != 0) {
          await resetNotificationCount();
        }
      }
    } else {
      showSnackBar(text: 'errorOccurred'.tr, snackBarType: SnackBarType.error);
    }
  }

  @override
  void onClose() {
    notificationsRefreshController.dispose();
    super.onClose();
  }

  void onRefresh() {
    notificationLoaded.value = false;
    loadNotifications();
    notificationsRefreshController.refreshToIdle();
    notificationsRefreshController.resetNoData();
  }
}
