import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class RegularClickableCardIcon extends StatelessWidget {
  const RegularClickableCardIcon({
    super.key,
    required this.onPressed,
    required this.title,
    required this.subTitle,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.trailingIconColor,
    required this.leadingIconColor,
    required this.borderRadius,
  });
  final Function onPressed;
  final IconData leadingIcon;
  final String title;
  final String subTitle;
  final IconData trailingIcon;
  final Color trailingIconColor;
  final Color leadingIconColor;
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: InkWell(
        hoverColor: Colors.grey.shade50,
        splashFactory: InkSparkle.splashFactory,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        onTap: () => onPressed(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                leadingIcon,
                color: leadingIconColor,
                size: 35,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18),
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
              ),
              const Spacer(),
              Icon(
                trailingIcon,
                color: trailingIconColor,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
