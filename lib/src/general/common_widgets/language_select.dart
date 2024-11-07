import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/assets_strings.dart';
import 'gif_button.dart';

class LanguageSelect extends StatelessWidget {
  const LanguageSelect(
      {super.key,
      required this.onEnglishLanguagePress,
      required this.onArabicLanguagePress});
  final Function onEnglishLanguagePress;
  final Function onArabicLanguagePress;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          height: 320,
          width: 700,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              AutoSizeText(
                'chooseLanguage'.tr,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GifButton(
                      gifPath: kUkFlagImage,
                      text: 'english'.tr,
                      onPressed: () => onEnglishLanguagePress(),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: GifButton(
                      gifPath: kSAFlagImage,
                      text: 'arabic'.tr,
                      onPressed: () => onArabicLanguagePress(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
