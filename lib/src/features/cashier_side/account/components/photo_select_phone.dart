import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/framed_button.dart';
import '../../../../general/general_functions.dart';

class PhotoSelectPhone extends StatelessWidget {
  const PhotoSelectPhone({
    super.key,
    required this.onCapturePhotoPress,
    required this.onChoosePhotoPress,
    required this.headerText,
  });
  final String headerText;
  final Function onCapturePhotoPress;
  final Function onChoosePhotoPress;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            headerText,
            style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            maxLines: 2,
          ),
          const SizedBox(height: 15.0),
          FramedIconButton(
            height: screenHeight * 0.11,
            title: 'pickGallery'.tr,
            subTitle: '',
            iconData: Icons.photo,
            onPressed: () => onChoosePhotoPress(),
          ),
          const SizedBox(height: 10.0),
          FramedIconButton(
            height: screenHeight * 0.11,
            title: 'capturePhoto'.tr,
            subTitle: '',
            iconData: Icons.camera_alt,
            onPressed: () => onCapturePhotoPress(),
          ),
        ],
      ),
    );
  }
}
