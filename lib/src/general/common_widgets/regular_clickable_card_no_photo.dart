import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RegularClickableCardNoP extends StatelessWidget {
  const RegularClickableCardNoP({
    super.key,
    required this.onPressed,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.iconColor,
  });
  final Function onPressed;

  final String title;
  final String subTitle;
  final IconData icon;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: InkWell(
          hoverColor: Colors.grey.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashFactory: InkSparkle.splashFactory,
          onTap: () => onPressed(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    if (subTitle.isNotEmpty)
                      AutoSizeText(
                        subTitle,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                        maxLines: 1,
                      ),
                  ],
                ),
                const Spacer(),
                Icon(
                  icon,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
