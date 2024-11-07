import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/constants/assets_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelectPhone extends StatelessWidget {
  const LanguageSelectPhone(
      {super.key,
      required this.onEnglishLanguagePress,
      required this.onArabicLanguagePress});
  final Function onEnglishLanguagePress;
  final Function onArabicLanguagePress;
  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
        fontSize: 25.0, fontWeight: FontWeight.w600, color: Colors.black54);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            'chooseLanguage'.tr,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            maxLines: 2,
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                splashFactory: InkSparkle.splashFactory,
                foregroundColor: Colors.black54,
              ),
              onPressed: () => onEnglishLanguagePress(),
              icon: Image.asset(
                kUkFlagImage,
                height: 60,
              ),
              label: SizedBox(
                width: 100,
                child: AutoSizeText(
                  'english'.tr,
                  style: textStyle,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                splashFactory: InkSparkle.splashFactory,
                foregroundColor: Colors.black54,
              ),
              onPressed: () => onArabicLanguagePress(),
              icon: Image.asset(
                kSAFlagImage,
                height: 60,
              ),
              label: SizedBox(
                width: 100,
                child: AutoSizeText(
                  'arabic'.tr,
                  style: textStyle,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
