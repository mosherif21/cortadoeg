import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class IconButtonText extends StatelessWidget {
  const IconButtonText({
    super.key,
    required this.onPress,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.buttonText,
    required this.isEnabled,
    required this.iconSize,
    required this.fontSize,
    required this.borderRadius,
  });
  final Function onPress;
  final bool isEnabled;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final double iconSize;
  final double fontSize;
  final double borderRadius;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.5,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            splashColor: isEnabled ? Colors.grey.shade500 : Colors.transparent,
            splashFactory: InkSparkle.splashFactory,
            onTap: isEnabled ? () => onPress() : null,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isEnabled ? iconColor : Colors.grey,
                    size: iconSize,
                  ),
                  const SizedBox(height: 5),
                  AutoSizeText(
                    buttonText,
                    maxLines: 1,
                    style: TextStyle(
                        color: isEnabled ? textColor : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
