import 'package:flutter/material.dart';

import '../../constants/assets_strings.dart';

class CoffeeCupAddIcon extends StatelessWidget {
  const CoffeeCupAddIcon({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kCoffeeCupImage,
      height: size,
    );
  }
}
