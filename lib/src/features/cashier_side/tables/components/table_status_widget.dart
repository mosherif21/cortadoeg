import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/common_widgets/ripple_circle.dart';
import 'package:flutter/material.dart';

class TableStatusWidget extends StatelessWidget {
  const TableStatusWidget({super.key, required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RippleCircle(color: color),
          const SizedBox(width: 10),
          AutoSizeText(
            text,
            style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w800,
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}
