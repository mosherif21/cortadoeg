import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemsSearchBar extends StatelessWidget {
  const ItemsSearchBar(
      {super.key,
      required this.searchBarTextController,
      required this.onSearchTap});
  final TextEditingController searchBarTextController;
  final Function onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: getScreenWidth(context) * 0.5,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchBarTextController,
              decoration: InputDecoration(
                hintText: 'searchItemsHint'.tr,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => onSearchTap(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              splashFactory: InkSparkle.splashFactory,
              elevation: 0,
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              overlayColor: Colors.white,
            ),
            child: AutoSizeText(
              'search'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
