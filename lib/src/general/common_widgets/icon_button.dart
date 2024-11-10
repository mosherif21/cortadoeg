import 'package:flutter/material.dart';

class IconElevatedButton extends StatelessWidget {
  const IconElevatedButton({
    super.key,
    required this.icon,
    required this.onClick,
    this.iconColor = Colors.white,
    this.buttonColor = Colors.black,
    this.iconSize = 22,
  });
  final IconData icon;
  final Function onClick;
  final Color? iconColor;
  final Color? buttonColor;
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
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
        onTap: () => onClick(),
      ),
    );
  }
}
