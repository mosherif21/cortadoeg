import 'package:flutter/material.dart';

class RegularTextButton extends StatelessWidget {
  const RegularTextButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      this.textColor = Colors.black87});
  final String buttonText;
  final Function onPressed;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          splashFactory: InkSparkle.splashFactory, overlayColor: Colors.grey),
      onPressed: () => onPressed(),
      child: Text(
        buttonText,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
