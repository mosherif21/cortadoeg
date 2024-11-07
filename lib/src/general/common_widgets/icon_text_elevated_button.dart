import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IconTextElevatedButton extends StatelessWidget {
  const IconTextElevatedButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onClick,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.buttonColor = Colors.black,
    this.fontSize = 15,
    this.iconSize = 22,
  });
  final IconData icon;
  final String text;
  final Function onClick;
  final Color? textColor;
  final Color? iconColor;
  final Color? buttonColor;
  final double? fontSize;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(25),
      color: buttonColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashFactory: InkSparkle.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
              const SizedBox(width: 10),
              AutoSizeText(
                text,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize),
              ),
            ],
          ),
        ),
        onTap: () => onClick(),
      ),
    );
  }
}
