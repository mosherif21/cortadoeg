import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BilledSelectionPhone extends StatelessWidget {
  const BilledSelectionPhone(
      {super.key,
      required this.tableIsEmptyPress,
      required this.reopenOrderPress});
  final Function tableIsEmptyPress;
  final Function reopenOrderPress;
  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            'chooseBilledOption'.tr,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            maxLines: 2,
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                splashFactory: InkSparkle.splashFactory,
                foregroundColor: Colors.black54,
              ),
              onPressed: () => tableIsEmptyPress(),
              icon: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  kEmptyTableImage,
                  height: 60,
                ),
              ),
              label: SizedBox(
                width: 150,
                child: AutoSizeText(
                  'tableIsEmpty'.tr,
                  style: textStyle,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                splashFactory: InkSparkle.splashFactory,
                foregroundColor: Colors.black54,
              ),
              onPressed: () => reopenOrderPress(),
              icon: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  kReopenOrderImage,
                  height: 60,
                ),
              ),
              label: SizedBox(
                width: 150,
                child: AutoSizeText(
                  'reopenOrder'.tr,
                  style: textStyle,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
