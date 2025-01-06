import 'package:auto_size_text/auto_size_text.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';
import '../controllers/account_screen_controller.dart';
import 'models.dart';

class AdminAccountOptionsListPhone extends StatelessWidget {
  const AdminAccountOptionsListPhone({super.key, required this.controller});
  final AdminAccountScreenController controller;
  @override
  Widget build(BuildContext context) {
    final screenType = GetScreenType(context);
    return Container(
      height: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(
              () => controller.isProfileImageLoaded.value
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 85,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              controller.isProfileImageChanged.value
                                  ? XFileImage(controller.profileImage.value!)
                                  : controller.profileMemoryImage.value ??
                                      AssetImage(
                                        controller.userInfo.gender == 'male'
                                            ? kMaleProfileImage
                                            : kFemaleProfileImage,
                                      ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: isLangEnglish() ? 10 : null,
                          left: isLangEnglish() ? null : -3,
                          child: Material(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              splashFactory: InkSparkle.splashFactory,
                              onTap: () => controller.onEditProfileTap(
                                isPhone: screenType.isPhone,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: const CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.white,
                      ),
                    ),
            ),
          ),
          AutoSizeText(
            controller.userInfo.name,
            maxLines: 2,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            getRoleName(controller.userInfo.role),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StretchingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 55,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () => controller.onAccountOptionTap(
                            index, screenType.isPhone),
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
                                    size: 26,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  AutoSizeText(
                                    'accountOption${index + 1}'.tr,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
