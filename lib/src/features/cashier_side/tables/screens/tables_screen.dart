import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/common_widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/cafe_layout.dart';
import '../components/cafe_layout_phone.dart';
import '../components/models.dart';
import '../components/new_order_tables_select.dart';
import '../components/new_order_tables_select_phone.dart';
import '../components/table_status_indicator_hint.dart';
import '../controllers/tables_page_controller.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({
    super.key,
    required this.navBarAccess,
    required this.tablesData,
  });
  final bool navBarAccess;
  final List<TableModel> tablesData;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(TablesPageController(tablesInsert: tablesData));
    controller.navBarAccess = navBarAccess;
    return Scaffold(
      appBar: !navBarAccess
          ? AppBar(
              leading: RegularBackButton(
                padding: 0,
                backOverride: controller.onBackPressed,
              ),
              elevation: 0,
              title: AutoSizeText(
                'tables'.tr,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                maxLines: 1,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            )
          : screenType.isPhone
              ? null
              : AppBar(
                  elevation: 0,
                  title: MainScreenPagesAppbar(
                    isPhone: screenType.isPhone,
                    appBarTitle: 'tablesView'.tr,
                    unreadNotification: true,
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
                    color: Colors.grey.shade100,
                    child: screenType.isPhone
                        ? CafeLayoutPhone(controller: controller)
                        : CafeLayout(controller: controller),
                  ),
                )
              ],
            ),
            Obx(
              () => controller.selectedTables.isNotEmpty
                  ? screenType.isPhone
                      ? NewOrderTablesSelectPhone(
                          tablesNo: controller.selectedTables,
                          onNewOrderTap: () => controller.onNewOrder(
                              isPhone: screenType.isPhone),
                        )
                      : NewOrderTablesSelect(
                          tablesNo: controller.selectedTables,
                          onNewOrderTap: () => controller.onNewOrder(
                              isPhone: screenType.isPhone),
                        )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
