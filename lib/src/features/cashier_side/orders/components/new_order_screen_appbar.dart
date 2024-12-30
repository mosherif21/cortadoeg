import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';

class NewOrderScreenAppbar extends StatelessWidget {
  const NewOrderScreenAppbar(
      {super.key,
      required this.searchBarTextController,
      required this.isTakeaway,
      this.tablesNo,
      required this.orderNumber,
      required this.titleFontSize});
  final TextEditingController searchBarTextController;
  final bool isTakeaway;
  final List<int>? tablesNo;
  final String orderNumber;
  final double titleFontSize;
  @override
  Widget build(BuildContext context) {
    return AnimSearchAppBar(
      keyboardType: TextInputType.text,
      cancelButtonTextStyle: const TextStyle(color: Colors.black87),
      cancelButtonText: 'cancel'.tr,
      hintText: 'searchItemsHint'.tr,
      hintStyle: const TextStyle(fontWeight: FontWeight.w600),
      cSearch: searchBarTextController,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        leading: const RegularBackButton(padding: 0),
        title: AutoSizeText(
          formatOrderDetails(
            orderNumber: orderNumber,
            isTakeaway: isTakeaway,
            tablesNo: tablesNo,
          ),
          maxLines: 2,
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
  required String orderNumber,
  required bool isTakeaway,
  required List<int>? tablesNo,
}) {
  final orderStr = 'orderNumber'.trParams({
    'number': orderNumber.toString(),
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
