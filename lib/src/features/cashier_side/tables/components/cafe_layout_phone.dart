import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/ripple_circle.dart';
import '../components/models.dart';
import '../controllers/tables_page_controller.dart';

class CafeLayoutPhone extends StatelessWidget {
  const CafeLayoutPhone({super.key, required this.controller});
  final TablesPageController controller;

  @override
  Widget build(BuildContext context) {
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 60,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Center(
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
          const SizedBox(height: 20),
          Expanded(
            child: AnimationLimiter(
              child: Obx(
                () => GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(
                    controller.tablesList.length,
                    (int phoneIndex) {
                      final isFirstColumn = phoneIndex % 2 == 0;
                      final logicalRow = phoneIndex ~/ 2;
                      final tabletIndex =
                          isFirstColumn ? 5 + logicalRow : logicalRow;
                      if (tabletIndex >= controller.tablesList.length) {
                        return const SizedBox();
                      }
                      final table = controller.tablesList[tabletIndex];
                      return AnimationConfiguration.staggeredGrid(
                        position: phoneIndex,
                        duration: const Duration(milliseconds: 300),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: controller.loadingTables.value
                                ? const TableLoading()
                                : InkWell(
                                    onTap: () => controller.onTableSelected(
                                        tabletIndex, true),
                                    child: Table(
                                      tableModel: table,
                                      selected: controller.selectedTables
                                          .contains(tabletIndex + 1),
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
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 60,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Center(
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
        ],
      ),
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
    return Column(
      children: [
        // Chair Left
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(height: 5),
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
                  'tableNumber'.trParams({
                    'number': tableModel.number.toString(),
                  }),
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
                  'tableNumber'.trParams({
                    'number': tableModel.number.toString(),
                  }),
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
        const SizedBox(height: 5),
        // Chair - Right
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
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
    return Column(
      children: [
        // Chair Left
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(height: 5),
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
        const SizedBox(height: 5),
        // Chair - Right
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, //New
                blurRadius: 3,
              )
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
