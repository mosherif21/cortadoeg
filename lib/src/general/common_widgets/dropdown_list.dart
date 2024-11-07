import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

class DropdownList extends StatelessWidget {
  const DropdownList({
    super.key,
    required this.hintText,
    required this.items,
    required this.dropDownController,
  });
  final String hintText;
  final List<String> items;
  final TextEditingController dropDownController;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      hintText: hintText,
      items: items,
      //controller: dropDownController,
      onChanged: (String? s) {},
    );
  }
}
