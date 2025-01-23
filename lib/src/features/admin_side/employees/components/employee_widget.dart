import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/general_functions.dart';

class EmployeeCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String gender;
  final String role;
  final Function onSelected;
  final Function onDelete;

  const EmployeeCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.gender,
    required this.role,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200, //New
                blurRadius: 10,
              ),
            ],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              splashFactory: InkSparkle.splashFactory,
              onTap: () => onSelected(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            gender == 'male'
                                ? kMaleProfileImage
                                : kFemaleProfileImage,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: AutoSizeText(
                            name,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AutoSizeText(
                          role,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: isLangEnglish() ? 10 : null,
          left: isLangEnglish() ? null : 10,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              splashFactory: InkSparkle.splashFactory,
              onTap: () => onDelete(),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingEmployee extends StatelessWidget {
  const LoadingEmployee({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Container(
            height: 120,
            width: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 30,
                  width: 100,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 20,
                  width: 40,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
