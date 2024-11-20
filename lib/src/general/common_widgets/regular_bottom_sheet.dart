import 'package:flutter/material.dart';
import 'package:get/get.dart';

showRegularBottomSheet(Widget child) {
  return Get.bottomSheet(
    Wrap(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              height: 7,
              width: 40,
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
