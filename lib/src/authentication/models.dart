import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../constants/enums.dart';

class EmployeeModel {
  final String id;
  String name;
  String email;
  String gender;
  Timestamp birthDate;
  String phone;
  String profileImageUrl;
  Role role;
  List<UserPermission> permissions;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'birthDate': birthDate,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'role': role.name, // Save enum as string
      'permissions': permissions.map((p) => p.name).toList(),
    };
  }

  factory EmployeeModel.fromFirestore(Map<String, dynamic> map, String id) {
    return EmployeeModel(
      id: id,
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      gender: map['gender'],
      birthDate: map['birthDate'],
      role: Role.values.firstWhere((r) => r.name == map['role']),
      permissions: (map['permissions'] as List<dynamic>)
          .map(
              (p) => UserPermission.values.firstWhere((perm) => perm.name == p))
          .toList(),
    );
  }
}

bool hasPermission(EmployeeModel employee, UserPermission requiredPermission) {
  return employee.permissions.contains(requiredPermission);
}

final Map<Role, List<UserPermission>> rolePermissions = {
  Role.admin: [
    UserPermission.manageEmployees,
    UserPermission.manageItems,
    UserPermission.manageInventory,
    UserPermission.viewSalesReports,
    UserPermission.viewCustodyReports,
    UserPermission.manageOrders,
    UserPermission.manageCustomers,
  ],
  Role.cashier: [
    UserPermission.finalizeOrders,
    UserPermission.manageCustomers,
    UserPermission.manageTables,
    UserPermission.editOrderItemsWithPass,
    UserPermission.returnOrdersWithPass,
    UserPermission.cancelOrders,
    UserPermission.manageOrders,
    UserPermission.manageDayShifts,
    UserPermission.openDrawerWithPass,
  ],
  Role.waiter: [
    UserPermission.cancelOrdersWithPass,
    UserPermission.manageCustomers,
    UserPermission.manageTables,
    UserPermission.manageOrders,
    UserPermission.editOrderItemsWithPass,
  ],
  Role.takeaway: [
    UserPermission.manageTakeawayOrders,
    UserPermission.editOrderItemsWithPass,
  ],
};

enum PasscodeType {
  editOrderItems,
  cancelOrders,
  openDrawer,
  manageDayShift,
  finalizeOrders,
  returnOrders,
}

enum UserPermission {
  editOrderItems,
  editOrderItemsWithPass,
  returnOrders,
  returnOrdersWithPass,
  manageTables,
  manageEmployees,
  manageItems,
  manageInventory,
  manageOrders,
  manageCustomers,
  viewSalesReports,
  viewCustodyReports,
  cancelOrders,
  cancelOrdersWithPass,
  finalizeOrders,
  finalizeOrdersWithPass,
  manageTakeawayOrders,
  manageDayShifts,
  openDrawer,
  openDrawerWithPass,
}

String getPermissionName(UserPermission permission) {
  switch (permission) {
    case UserPermission.editOrderItems:
      return 'editOrderItems'.tr;
    case UserPermission.editOrderItemsWithPass:
      return 'editOrderItemsWithPass'.tr;
    case UserPermission.returnOrders:
      return 'returnOrders'.tr;
    case UserPermission.returnOrdersWithPass:
      return 'returnOrdersWithPass'.tr;
    case UserPermission.manageTables:
      return 'manageTables'.tr;
    case UserPermission.manageEmployees:
      return 'manageEmployees'.tr;
    case UserPermission.manageItems:
      return 'manageItems'.tr;
    case UserPermission.manageInventory:
      return 'manageInventory'.tr;
    case UserPermission.manageOrders:
      return 'manageOrders'.tr;
    case UserPermission.manageCustomers:
      return 'manageCustomers'.tr;
    case UserPermission.viewSalesReports:
      return 'viewSalesReports'.tr;
    case UserPermission.viewCustodyReports:
      return 'viewCustodyReports'.tr;
    case UserPermission.cancelOrders:
      return 'cancelOrders'.tr;
    case UserPermission.cancelOrdersWithPass:
      return 'cancelOrdersWithPass'.tr;
    case UserPermission.finalizeOrders:
      return 'finalizeOrders'.tr;
    case UserPermission.finalizeOrdersWithPass:
      return 'finalizeOrdersWithPass'.tr;
    case UserPermission.manageTakeawayOrders:
      return 'manageTakeawayOrders'.tr;
    case UserPermission.manageDayShifts:
      return 'manageDayShifts'.tr;
    case UserPermission.openDrawer:
      return 'openDrawer'.tr;
    case UserPermission.openDrawerWithPass:
      return 'openDrawerWithPass'.tr;
  }
}
