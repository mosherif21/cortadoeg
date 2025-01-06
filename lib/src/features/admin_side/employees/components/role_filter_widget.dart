import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/admin_side/account/components/models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../general/general_functions.dart';

class EmployeeRoleWidget extends StatelessWidget {
  const EmployeeRoleWidget(
      {super.key, required this.selectedRole, required this.onSelect});

  final int selectedRole;
  final Function(int) onSelect;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 40,
        child: StretchingOverscrollIndicator(
          axisDirection:
              isLangEnglish() ? AxisDirection.right : AxisDirection.left,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: Role.values.length,
            itemBuilder: (context, index) {
              return RoleFilterItem(
                icon: rolesIconList[index],
                role: Role.values[index],
                isSelected: index == selectedRole,
                onSelect: () => onSelect(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

final rolesIconList = [
  Icons.select_all,
  Icons.admin_panel_settings_rounded,
  FontAwesomeIcons.cashRegister,
  Icons.table_bar_rounded,
  Icons.delivery_dining_rounded,
];

class RoleFilterItem extends StatelessWidget {
  const RoleFilterItem({
    super.key,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onSelect,
  });

  final IconData icon;
  final Role role;
  final Function onSelect;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: role == Role.takeaway
          ? const BoxConstraints(maxWidth: 200)
          : const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.black : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashFactory: InkSparkle.splashFactory,
          onTap: isSelected ? null : () => onSelect(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: getRoleName(role),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  ConstrainedBox(
                    constraints: role == Role.takeaway
                        ? const BoxConstraints(maxWidth: 130)
                        : const BoxConstraints(maxWidth: 70),
                    child: Text(
                      getRoleName(role),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
