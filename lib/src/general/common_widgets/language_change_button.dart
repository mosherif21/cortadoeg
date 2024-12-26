import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../general_functions.dart';

class ButtonLanguageSelect extends StatelessWidget {
  const ButtonLanguageSelect({
    super.key,
    required this.color,
  });
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLangEnglish() ? Alignment.centerLeft : Alignment.centerRight,
      child: SizedBox(
        width: isLangEnglish() ? 140.0 : 90.0,
        child: TextButton(
          style: TextButton.styleFrom(
            splashFactory: InkSparkle.splashFactory,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25))),
            foregroundColor: Colors.grey.shade600,
          ),
          onPressed: () => displayChangeLang(),
          child: Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: color,
                size: 24.0,
              ),
              const SizedBox(width: 5),
              AutoSizeText(
                'lang'.tr,
                style: TextStyle(
                    fontFamily: 'Bruno Ace', fontSize: 17.0, color: color),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
