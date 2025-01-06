import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/gif_button.dart';

class PhotoSelect extends StatelessWidget {
  const PhotoSelect({
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          height: 320,
          width: 700,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              AutoSizeText(
                headerText,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: IconElevatedButton(
                      iconData: Icons.photo,
                      text: 'pickGallery'.tr,
                      onPressed: () => onChoosePhotoPress(),
                      iconColor: Colors.black,
                      textColor: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: IconElevatedButton(
                      iconData: Icons.camera_alt,
                      text: 'capturePhoto'.tr,
                      onPressed: () => onCapturePhotoPress(),
                      iconColor: Colors.black,
                      textColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
