import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/ripple_circle.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../../main_screen/components/main_screen_pages_appbar.dart';
import '../components/models.dart';
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
      appBar: AppBar(
        elevation: 0,
        title: MainScreenPagesAppbar(
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
                    child: CafeLayout(controller: controller),
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

class CafeLayout extends StatelessWidget {
  const CafeLayout({super.key, required this.controller});
  final TablesPageController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 120,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 5.0,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 5 : 15),
              topRight: Radius.circular(isLangEnglish() ? 15 : 5),
              bottomLeft: Radius.circular(isLangEnglish() ? 5 : 15),
              bottomRight: Radius.circular(isLangEnglish() ? 15 : 5),
            ),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: isLangEnglish() ? 1 : 3,
              child: Text(
                'counter'.tr,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Obx(
                  () => controller.loadingTables.value
                      ? const TableLoading()
                      : InkWell(
                          onTap: () => controller.onTableSelected(index),
                          child: Table(
                            tableModel: controller.tablesData[index],
                            selected:
                                controller.selectedTables.contains(index + 1),
                          ),
                        ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 120,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 5.0,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 15 : 5),
              topRight: Radius.circular(isLangEnglish() ? 5 : 15),
              bottomLeft: Radius.circular(isLangEnglish() ? 15 : 5),
              bottomRight: Radius.circular(isLangEnglish() ? 5 : 15),
            ),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: isLangEnglish() ? 3 : 1,
              child: Text(
                'door'.tr,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Table extends StatelessWidget {
  final TableModel tableModel;
  final bool selected;

  const Table({
    super.key,
    required this.tableModel,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chair Left
        Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 10 : 5),
              topRight: Radius.circular(isLangEnglish() ? 5 : 10),
              bottomLeft: Radius.circular(isLangEnglish() ? 10 : 5),
              bottomRight: Radius.circular(isLangEnglish() ? 5 : 10),
            ),
          ),
        ),
        const SizedBox(width: 5),
        // Table
        Container(
          width: 98,
          height: 98,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            border: selected
                ? Border.all(
                    color: Colors.green,
                    width: 1.5,
                  )
                : null,
          ),
          child: DragTarget<TableModel>(
            onWillAcceptWithDetails: (incomingOrder) =>
                TablesPageController.instance.acceptSwitchTable(
                    incomingOrder.data.number, tableModel.number),
            onAcceptWithDetails: (incomingOrder) => TablesPageController
                .instance
                .switchTables(incomingOrder.data.number, tableModel.number),
            builder: (context, candidateData, rejectData) => Draggable(
              data: tableModel,
              childWhenDragging: const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
              ),
              feedback: RippleCircle(
                color: tableModel.status == TableStatus.available
                    ? Colors.green
                    : tableModel.status == TableStatus.occupied
                        ? Colors.amber
                        : tableModel.status == TableStatus.billed
                            ? Colors.black
                            : Colors.grey.shade400,
                innerRadius: 20,
                outerRadius: 30,
                child: Text(
                  'T-${tableModel.number.toString()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              child: RippleCircle(
                color: tableModel.status == TableStatus.available
                    ? Colors.green
                    : tableModel.status == TableStatus.occupied
                        ? Colors.amber
                        : tableModel.status == TableStatus.billed
                            ? Colors.black
                            : Colors.grey.shade400,
                innerRadius: 20,
                outerRadius: 30,
                child: Text(
                  'T-${tableModel.number.toString()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        // Chair - Right
        Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 5 : 10),
              topRight: Radius.circular(isLangEnglish() ? 10 : 5),
              bottomLeft: Radius.circular(isLangEnglish() ? 5 : 10),
              bottomRight: Radius.circular(isLangEnglish() ? 10 : 5),
            ),
          ),
        ),
        // Table
      ],
    );
  }
}

class TableLoading extends StatelessWidget {
  const TableLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chair Left
        Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 15 : 5),
              topRight: Radius.circular(isLangEnglish() ? 5 : 15),
              bottomLeft: Radius.circular(isLangEnglish() ? 15 : 5),
              bottomRight: Radius.circular(isLangEnglish() ? 5 : 15),
            ),
          ),
        ),
        const SizedBox(width: 5),
        // Table
        Container(
          width: 98,
          height: 98,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 40,
              height: 60,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.red),
            ),
          ),
        ),
        const SizedBox(width: 5),
        // Chair - Right
        Container(
          width: 30,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLangEnglish() ? 5 : 15),
              topRight: Radius.circular(isLangEnglish() ? 15 : 5),
              bottomLeft: Radius.circular(isLangEnglish() ? 5 : 15),
              bottomRight: Radius.circular(isLangEnglish() ? 15 : 5),
            ),
          ),
        ),
        // Table
      ],
    );
  }
}
