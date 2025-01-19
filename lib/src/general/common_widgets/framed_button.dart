import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class FramedIconButton extends StatelessWidget {
  const FramedIconButton({
    super.key,
    required this.title,
    required this.subTitle,
    required this.iconData,
    required this.onPressed,
    required this.height,
  });
  final String title;
  final String subTitle;
  final IconData iconData;
  final Function onPressed;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      color: Colors.grey.shade200,
      child: InkWell(
        splashFactory: InkSparkle.splashFactory,
        borderRadius: BorderRadius.circular(10.0),
        onTap: () => onPressed(),
        child: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                iconData,
                size: height * 0.6,
                color: Colors.black,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400),
                    maxLines: 1,
                  ),
                  if (subTitle.isNotEmpty)
                    AutoSizeText(
                      subTitle,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
