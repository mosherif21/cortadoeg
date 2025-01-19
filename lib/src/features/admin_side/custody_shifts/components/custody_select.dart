import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/gif_button.dart';

class CustodySelect extends StatelessWidget {
  const CustodySelect({
    super.key,
    required this.onViewTransactionsPress,
    required this.onPrintReceiptPress,
    required this.headerText,
  });
  final String headerText;
  final Function onViewTransactionsPress;
  final Function onPrintReceiptPress;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          height: 320,
          width: 700,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              AutoSizeText(
                headerText,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: IconElevatedButton(
                      iconData: Icons.currency_exchange_rounded,
                      text: 'viewTransactions'.tr,
                      onPressed: () => onViewTransactionsPress(),
                      iconColor: Colors.black,
                      textColor: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: IconElevatedButton(
                      iconData: Icons.receipt_long_rounded,
                      text: 'printInvoice'.tr,
                      onPressed: () => onPrintReceiptPress(),
                      iconColor: Colors.black,
                      textColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
