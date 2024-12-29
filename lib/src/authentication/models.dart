import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/enums.dart';

class EmployeeModel {
  final String id;
  String name;
  String email;
  String? gender;
  Timestamp? birthDate;
  String phone;
  Role role;
  List<UserPermission> permissions;

  EmployeeModel({
    required this.id,
    required this.name,
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
    UserPermission.manageProducts,
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
  manageProducts,
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
