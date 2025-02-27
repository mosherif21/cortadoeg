import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

import '../../../../authentication/models.dart';

class PermissionChip extends StatelessWidget {
  final UserPermission permission;
  final bool isSelected;
  final bool isPhone;
  final ValueChanged<bool> onChanged;

  const PermissionChip({
    super.key,
    required this.permission,
    required this.isSelected,
    required this.onChanged,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Row(
        children: [
          RoundCheckBox(
            onTap: (_) => onChanged(!isSelected),
            checkedColor: Colors.black,
            uncheckedColor: Colors.white,
            size: isPhone ? 30 : 26,
            isChecked: isSelected,
          ),
          const SizedBox(width: 10),
          AutoSizeText(
            getPermissionName(permission),
            maxLines: 1,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: isPhone ? 18 : 14),
          ),
        ],
      ),
    );
  }
}
