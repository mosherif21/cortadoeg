import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegularBottomSheet {
  static void showRegularBottomSheet(Widget child) async {
    await Get.bottomSheet(
      Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20)),
              ),
              child,
            ],
          )
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      enterBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  static void hideBottomSheet() {
    if (Get.isBottomSheetOpen!) Get.back();
  }
}
