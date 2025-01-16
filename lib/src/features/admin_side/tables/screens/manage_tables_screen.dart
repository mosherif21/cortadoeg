import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../../cashier_side/tables/components/table_status_indicator_hint.dart';
import '../../admin_main_screen/components/main_appbar.dart';
import '../components/cafe_layout.dart';
import '../components/cafe_layout_phone.dart';
import '../components/new_order_tables_select.dart';
import '../components/new_order_tables_select_phone.dart';
import '../controllers/manage_tables_controller.dart';

class ManageTablesScreen extends StatelessWidget {
  const ManageTablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(ManageTablesPageController());
    return Scaffold(
      appBar: screenType.isPhone
          ? null
          : AppBar(
              elevation: 0,
              title: MainScreenAppbar(
                isPhone: screenType.isPhone,
                appBarTitle: 'tables'.tr,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionDivider(),
                const TableStatusIndicatorHint(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      image: const DecorationImage(
                        image: AssetImage(kLogoImage),
                        opacity: 0.05,
                      ),
                    ),
                    child: RefreshConfiguration(
                      headerTriggerDistance: 60,
                      maxOverScrollExtent: 20,
                      enableLoadingWhenFailed: true,
                      hideFooterWhenNotFull: true,
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
                          textStyle: const TextStyle(color: Colors.black54),
                          failedIcon:
                              const Icon(Icons.error, color: Colors.black54),
                          completeIcon:
                              const Icon(Icons.done, color: Colors.black54),
                          idleIcon: const Icon(Icons.arrow_downward,
                              color: Colors.black54),
                          releaseIcon:
                              const Icon(Icons.refresh, color: Colors.black54),
                        ),
                        controller: controller.tablesRefreshController,
                        onRefresh: () => controller.onRefresh(),
                        child: screenType.isPhone
                            ? AdminCafeLayoutPhone(controller: controller)
                            : AdminCafeLayout(controller: controller),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Obx(
              () => controller.selectedTable.value != null
                  ? screenType.isPhone
                      ? ManageTablesSelectPhone(
                          tableNo: controller.selectedTable,
                          tableModel: controller.selectedTableModel,
                          onSetAvailableTap: () =>
                              controller.onSetAvailableTap(),
                          onSetUnavailableTap: () =>
                              controller.onSetUnavailableTap(),
                        )
                      : ManageTablesSelect(
                          tableNo: controller.selectedTable,
                          tableModel: controller.selectedTableModel,
                          onSetAvailableTap: () =>
                              controller.onSetAvailableTap(),
                          onSetUnavailableTap: () =>
                              controller.onSetUnavailableTap(),
                        )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
