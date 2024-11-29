import '../constants/enums.dart';

class EmployeeModel {
  final String id;
  String name;
  String email;
  String phone;
  Role role;
  List<UserPermission> permissions;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name, // Save enum as string
      'permissions': permissions.map((p) => p.name).toList(),
    };
  }

  // Create EmployeeModel from Firestore DocumentSnapshot
  factory EmployeeModel.fromFirestore(Map<String, dynamic> map, String id) {
    return EmployeeModel(
      id: id,
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
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
    UserPermission.viewReports,
    UserPermission.manageOrders,
    UserPermission.processPayments,
  ],
  Role.cashier: [
    UserPermission.processPayments,
    UserPermission.manageCustomers,
    UserPermission.viewSalesReports,
    UserPermission.viewCustodyReports,
    UserPermission.editOrderItemsWithPass,
  ],
  Role.waiter: [
    UserPermission.createOrders,
    UserPermission.updateOrders,
    UserPermission.finalizeOrders,
    UserPermission.viewAssignedTables,
  ],
  Role.takeaway: [
    UserPermission.createTakeawayOrders,
    UserPermission.finalizeTakeawayOrders,
    UserPermission.viewTakeawayReports,
  ],
};

enum UserPermission {
  editOrderItems,
  editOrderItemsWithPass,
  manageEmployees,
  manageProducts,
  manageInventory,
  viewReports,
  manageOrders,
  processPayments,
  manageCustomers,
  viewSalesReports,
  viewCustodyReports,
  createOrders,
  updateOrders,
  finalizeOrders,
  viewAssignedTables,
  createTakeawayOrders,
  finalizeTakeawayOrders,
  viewTakeawayReports,
}
