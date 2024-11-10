import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/assets_strings.dart';

class CoffeeCupAddIcon extends StatelessWidget {
  const CoffeeCupAddIcon({super.key, required this.size, this.addSize = 9});
  final double size;
  final double addSize;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          kCoffeeCupImage,
          height: size,
        ),
        Positioned(
          top: 4,
          bottom: 0,
          left: 0,
          right: 0,
          child: Icon(
            FontAwesomeIcons.plus,
            color: Colors.white,
            size: addSize,
          ),
        ),
      ],
    );
  }
}
