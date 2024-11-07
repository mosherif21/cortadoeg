import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  const TextHeader({
    super.key,
    required this.headerText,
    required this.fontSize,
    required this.maxLines,
  });
  final String headerText;
  final double fontSize;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: AutoSizeText(
        headerText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        maxLines: maxLines,
        minFontSize: 10,
      ),
    );
  }
}
