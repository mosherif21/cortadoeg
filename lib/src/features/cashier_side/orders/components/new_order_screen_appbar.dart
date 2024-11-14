import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';

class NewOrderScreenAppbar extends StatelessWidget {
  const NewOrderScreenAppbar(
      {super.key,
      required this.searchBarTextController,
      required this.isTakeaway,
      this.tablesNo,
      required this.currentOrderId,
      required this.titleFontSize});
  final TextEditingController searchBarTextController;
  final bool isTakeaway;
  final List<int>? tablesNo;
  final String currentOrderId;
  final double titleFontSize;
  @override
  Widget build(BuildContext context) {
    return AnimSearchAppBar(
      keyboardType: TextInputType.text,
      cancelButtonTextStyle: const TextStyle(color: Colors.black87),
      cancelButtonText: 'cancel'.tr,
      hintText: 'searchItemsHint'.tr,
      cSearch: searchBarTextController,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        leading: const RegularBackButton(padding: 0),
        title: Text(
          formatOrderDetails(
            currentOrderId: currentOrderId,
            isTakeaway: isTakeaway,
            tablesNo: tablesNo,
          ),
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize),
        ),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.grey.shade100,
      ),
    );
  }
}

String formatOrderDetails({
  required String currentOrderId,
  required bool isTakeaway,
  required List<int>? tablesNo,
}) {
  final orderStr = 'orderNumber'.trParams({
    'number': currentOrderId.toString(),
  });
  String locationStr;
  if (isTakeaway) {
    locationStr = 'takeawayOrder'.tr;
  } else {
    locationStr = '${'table'.tr} (';
    locationStr += tablesNo!.map((tableNo) {
      return 'tableNumber'.trParams({'number': tableNo.toString()});
    }).join(', ');
    locationStr += ')';
  }
  return '$orderStr - $locationStr';
}
