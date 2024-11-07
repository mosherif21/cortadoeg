import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';

class TableSelectionWidget extends StatelessWidget {
  final int tableNo;
  final VoidCallback onCancel;

  const TableSelectionWidget({
    super.key,
    required this.tableNo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = isLangEnglish();
    return Container(
      margin:
          EdgeInsets.only(right: isEnglish ? 20 : 0, left: isEnglish ? 0 : 20),
      child: GestureDetector(
        onTap: onCancel,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Grey border color
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'T-$tableNo',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Cancel icon in red circle
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
