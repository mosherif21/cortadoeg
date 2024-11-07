import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../general_functions.dart';

Widget clickableLabeledImage({
  required img,
  required label,
}) {
  return Stack(
    children: <Widget>[
      Container(
          margin: EdgeInsets.only(bottom: isLangEnglish() ? 20.0 : 30),
          padding: const EdgeInsets.all(15),
          child: Image.asset(img, fit: BoxFit.contain, width: 1000.0)),
      Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
          child: AutoSizeText(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ),
      ),
    ],
  );
}
