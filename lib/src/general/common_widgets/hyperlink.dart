import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchURL(url: url),
      child: AutoSizeText(
        url,
        style: const TextStyle(
            decoration: TextDecoration.underline, // Underline the text
            color: Colors.blue,
            decorationColor: Colors.blue,
            fontSize: 18),
      ),
    );
  }
}
