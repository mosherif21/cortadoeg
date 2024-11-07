import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Text(
            'or'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          const Expanded(
            child: Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
          )
        ],
      ),
    );
  }
}
