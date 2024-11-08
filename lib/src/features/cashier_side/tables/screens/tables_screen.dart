import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/cafe_layout.dart';
import '../components/cafe_layout_phone.dart';
import '../components/new_order_tables_widget.dart';
import '../components/table_status_indicator_hint.dart';
import '../controllers/tables_page_controller.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final screenType = GetScreenType(context);
    final controller = Get.put(TablesPageController());
    return Scaffold(
      appBar: screenType.isPhone
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
                  ? NewOrderTablesWidget(
                      tablesNo: controller.selectedTables,
                      onNewOrderTap: () {},
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
