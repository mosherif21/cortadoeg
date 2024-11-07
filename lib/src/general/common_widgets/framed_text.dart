import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FramedText extends StatelessWidget {
  const FramedText({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
  });
  final String text;
  final Color color;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: AutoSizeText(
          text,
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              color: Colors.white),
        ),
      ),
    );
  }
}
