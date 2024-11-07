import 'package:flutter/material.dart';

class RippleCircle extends StatelessWidget {
  final Color color;
  final double innerRadius;
  final double outerRadius;
  final Widget? child;

  const RippleCircle({
    super.key,
    required this.color,
    this.innerRadius = 8.0,
    this.outerRadius = 12.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Circle
        Container(
          width: outerRadius * 2,
          height: outerRadius * 2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        // Inner Circle
        CircleAvatar(
          radius: innerRadius,
          backgroundColor: color,
          child: child != null ? Center(child: child!) : null,
        ),
      ],
    );
  }
}
