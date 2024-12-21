import 'package:cortadoeg/src/features/cashier_side/tables/components/table_status_widget.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableStatusIndicatorHint extends StatelessWidget {
  const TableStatusIndicatorHint({super.key});

  @override
  Widget build(BuildContext context) {
    return StretchingOverscrollIndicator(
      axisDirection: isLangEnglish() ? AxisDirection.right : AxisDirection.left,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TableStatusWidget(
              text: 'available'.tr,
              color: Colors.green,
            ),
            TableStatusWidget(
              text: 'occupied'.tr,
              color: Colors.amber,
            ),
            TableStatusWidget(
              text: 'unavailable'.tr,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
