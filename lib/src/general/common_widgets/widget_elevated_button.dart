import 'package:flutter/material.dart';

class WidgetElevatedButton extends StatelessWidget {
  const WidgetElevatedButton({
    super.key,
    required this.onClick,
    this.buttonColor = Colors.black,
    required this.widget,
  });

  final Function onClick;
  final Widget widget;
  final Color? buttonColor;

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
          padding: const EdgeInsets.all(5),
          child: widget,
        ),
        onTap: () => onClick(),
      ),
    );
  }
}
