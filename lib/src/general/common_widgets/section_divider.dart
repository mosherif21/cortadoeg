import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade100,
            thickness: 2.0,
          ),
        ),
      ],
    );
  }
}
