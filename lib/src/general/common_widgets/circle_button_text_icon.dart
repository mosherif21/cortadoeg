import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CircleButtonIconAndText extends StatelessWidget {
  const CircleButtonIconAndText({
    super.key,
    required this.onPressed,
    required this.buttonText,
    required this.iconColor,
    required this.buttonColor,
    required this.icon,
    required this.splashColor,
  });
  final Function onPressed;
  final String buttonText;
  final Widget icon;
  final Color iconColor;
  final Color buttonColor;
  final Color splashColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          shape: const CircleBorder(),
          color: buttonColor,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashFactory: InkSparkle.splashFactory,
            splashColor: splashColor,
            highlightColor: splashColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: icon,
            ),
            onTap: () => onPressed(),
          ),
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(
          buttonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
