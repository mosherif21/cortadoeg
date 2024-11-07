import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NoFrameClickableCard extends StatelessWidget {
  const NoFrameClickableCard({
    super.key,
    required this.onPressed,
    required this.title,
    required this.subTitle,
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.leadingIconSize,
    required this.trailingIcon,
    required this.trailingIconColor,
    required this.padding,
  });
  final Function onPressed;
  final String title;
  final String subTitle;
  final IconData leadingIcon;
  final double leadingIconSize;
  final Color leadingIconColor;
  final IconData trailingIcon;
  final Color trailingIconColor;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        hoverColor: Colors.grey.shade50,
        splashFactory: InkSparkle.splashFactory,
        onTap: () => onPressed(),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                leadingIcon,
                color: leadingIconColor,
                size: leadingIconSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18),
                      maxLines: 1,
                    ),
                    if (subTitle.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 5),
                          AutoSizeText(
                            subTitle,
                            style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                            maxLines: 2,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                trailingIcon,
                color: trailingIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
