import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextWithTitle extends StatelessWidget {
  const TextWithTitle({super.key, required this.title, required this.text});
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AutoSizeText(
          '$title:  ',
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
        ),
        AutoSizeText(
          text,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
