import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextHeaderWithButton extends StatelessWidget {
  const TextHeaderWithButton(
      {super.key,
      required this.headerText,
      required this.onPressed,
      required this.buttonText});
  final String headerText;
  final Function onPressed;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: AutoSizeText(
            headerText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
          ),
        ),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            splashFactory: InkSparkle.splashFactory,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            foregroundColor: Colors.grey.shade600,
          ),
          onPressed: () => onPressed(),
          child: AutoSizeText(
            buttonText,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
