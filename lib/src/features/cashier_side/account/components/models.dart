import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';

const accountOptionIcon = [
  Icons.account_circle_rounded,
  Icons.lock_outline_rounded,
  Icons.language_rounded,
  Icons.logout_rounded,
];
String getRoleName(Role role) {
  switch (role) {
    case Role.cashier:
      return 'cashier'.tr;
    case Role.takeaway:
      return 'takeawayRole'.tr;
    case Role.waiter:
      return 'waiter'.tr;
    case Role.admin:
      return 'admin'.tr;
  }
}
