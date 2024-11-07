import 'package:flutter/material.dart';

class RegularCard extends StatelessWidget {
  const RegularCard({
    super.key,
    required this.child,
    required this.padding,
  });
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, //New
            blurRadius: 5.0,
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Center(child: child),
    );
  }
}
