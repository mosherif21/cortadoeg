import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/general_functions.dart';
import '../components/no_notifications.dart';
import '../components/notification_item.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final screenType = GetScreenType(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const RegularBackButton(padding: 0),
        title: AutoSizeText(
          'notifications'.tr,
          maxLines: 1,
        ),
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.w600, color: Colors.black),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: RefreshConfiguration(
              headerTriggerDistance: 60,
              maxOverScrollExtent: 20,
              enableLoadingWhenFailed: true,
              hideFooterWhenNotFull: true,
              child: AnimationLimiter(
                child: SmartRefresher(
                  enablePullDown: true,
                  header: ClassicHeader(
                    completeDuration: const Duration(milliseconds: 0),
                    releaseText: 'releaseToRefresh'.tr,
                    refreshingText: 'refreshing'.tr,
                    idleText: 'pullToRefresh'.tr,
                    completeText: 'refreshCompleted'.tr,
                    iconPos: isLangEnglish()
                        ? IconPosition.left
                        : IconPosition.right,
                    textStyle: const TextStyle(color: Colors.grey),
                    failedIcon: const Icon(Icons.error, color: Colors.grey),
                    completeIcon: const Icon(Icons.done, color: Colors.grey),
                    idleIcon:
                        const Icon(Icons.arrow_downward, color: Colors.grey),
                    releaseIcon: const Icon(Icons.refresh, color: Colors.grey),
                  ),
                  controller: controller.notificationsRefreshController,
                  onRefresh: () => controller.onRefresh(),
                  child: Obx(
                    () => controller.notificationLoaded.value &&
                            controller.notificationList.isEmpty
                        ? const NoNotifications()
                        : GridView.builder(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: screenType.isPhone ? 1 : 3,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: !controller.notificationLoaded.value
                                ? screenType.isPhone
                                    ? 10
                                    : 15
                                : controller.notificationList.isNotEmpty
                                    ? controller.notificationList.length
                                    : 1,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 300),
                                columnCount: screenType.isPhone ? 1 : 3,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: !controller.notificationLoaded.value
                                        ? const LoadingNotificationWidget()
                                        : NotificationWidget(
                                            notificationItem: controller
                                                .notificationList[index]),
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
    );
  }
}
