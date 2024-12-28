import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class LinkAccountButton extends StatelessWidget {
  const LinkAccountButton({
    super.key,
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
  });
  final String buttonText;
  final String imagePath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          splashFactory: InkSparkle.splashFactory,
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPressed(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(imagePath),
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: AutoSizeText(
                    buttonText,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
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
