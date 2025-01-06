import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models.dart';

class AccountOptionWidget extends StatelessWidget {
  const AccountOptionWidget({
    super.key,
    required this.chosen,
    required this.index,
    required this.onTap,
  });

  final bool chosen;
  final int index;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: chosen ? null : () => onTap(),
          splashFactory: InkSparkle.splashFactory,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    Icon(
                      accountOptionIcon[index],
                      size: 24,
                      color: chosen ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    AutoSizeText(
                      'accountOption${index + 1}'.tr,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: chosen ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (chosen)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: double.maxFinite,
                  width: 5,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
