import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RoundedElevatedButton extends StatelessWidget {
  const RoundedElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.enabled,
    required this.color,
  });
  final String buttonText;
  final Function onPressed;
  final bool enabled;
  final Color color;
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
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
          ),
          onPressed: enabled ? () => onPressed() : null,
          child: AutoSizeText(
            buttonText,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
