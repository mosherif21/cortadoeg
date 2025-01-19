import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/framed_button.dart';
import '../../../../general/general_functions.dart';

class CustodySelectPhone extends StatelessWidget {
  const CustodySelectPhone({
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
    final screenHeight = getScreenHeight(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            headerText,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            maxLines: 2,
          ),
          const SizedBox(height: 15.0),
          FramedIconButton(
            height: screenHeight * 0.11,
            title: 'viewTransactions'.tr,
            subTitle: '',
            iconData: Icons.currency_exchange_rounded,
            onPressed: () => onViewTransactionsPress(),
          ),
          const SizedBox(height: 10.0),
          FramedIconButton(
            height: screenHeight * 0.11,
            title: 'printInvoice'.tr,
            subTitle: '',
            iconData: Icons.receipt_long_rounded,
            onPressed: () => onPrintReceiptPress(),
          ),
        ],
      ),
    );
  }
}
