import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RoundedImageElevatedButton extends StatelessWidget {
  const RoundedImageElevatedButton(
      {super.key,
      required this.buttonText,
      required this.imagePath,
      required this.onPressed});
  final String buttonText;
  final String imagePath;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      color: Colors.grey.shade200,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        splashFactory: InkSparkle.splashFactory,
        onTap: () => onPressed(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 55,
              ),
              const SizedBox(height: 6),
              AutoSizeText(buttonText, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
