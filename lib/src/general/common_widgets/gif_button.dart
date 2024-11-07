import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GifButton extends StatelessWidget {
  final String gifPath;
  final String text;
  final VoidCallback onPressed;

  const GifButton({
    super.key,
    required this.gifPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        elevation: 5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      child: Column(
        children: [
          Image.asset(
            gifPath,
            height: 100,
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            text,
            style: const TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
