import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class LinkAccountButton extends StatelessWidget {
  const LinkAccountButton({
    super.key,
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.enabled,
  });
  final String buttonText;
  final String imagePath;
  final Function onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            splashFactory: InkSparkle.splashFactory,
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: backgroundColor == Colors.white
                ? Colors.grey.shade500
                : Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
          onPressed: enabled ? () => onPressed() : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(imagePath),
                  height: 35.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: AutoSizeText(
                    buttonText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
