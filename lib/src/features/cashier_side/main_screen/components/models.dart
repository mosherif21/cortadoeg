import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  sale, // Sale transaction
  completeSale, // Sale transaction
  reopenSale, // Reopen sale transaction
  returnSale, // Return transaction
  payIn, // Pay-in transaction
  payOut, // Pay-out transaction
  cashDrop, // Cash drop transaction
}

class CustodyTransaction {
  final String id; // Document ID (optional for identification)
  final TransactionType type; // Type of transaction
  final double amount; // Amount involved in the transaction
  final String description; // Optional description or notes
  final Timestamp timestamp; // When the transaction occurred

  CustodyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  // Convert Firestore document to CustodyTransaction instance
  factory CustodyTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustodyTransaction(
      id: doc.id,
      type: TransactionType.values[data['type']],
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  // Convert CustodyTransaction instance to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.index,
      'amount': amount,
      'description': description,
      'timestamp': timestamp,
    };
  }
}

class CustodyReport {
  final String id; // Document ID (optional, for identification)
  final Timestamp openingTime; // Time the drawer was opened
  final Timestamp closingTime; // Time the drawer was opened
  final double openingAmount; // Amount at opening
  final double cashPaymentsNet; // Cash received net of returns
  final double totalPayIns; // Total pay-ins
  final double totalPayOuts; // Total pay-outs
  final double cashDrop; // Total cash drops
  double closingAmount; // Actual cash in the drawer at closing
  double expectedDrawerMoney; // Expected cash in the drawer
  double difference; // Difference between actual and expected amounts
  final int drawerOpenCount; // Number of manual drawer openings
  final bool isActive;

  CustodyReport({
    required this.id,
    required this.openingTime,
    required this.closingTime,
    required this.openingAmount,
    required this.cashPaymentsNet,
    required this.totalPayIns,
    required this.totalPayOuts,
    required this.cashDrop,
    required this.closingAmount,
    required this.expectedDrawerMoney,
    required this.difference,
    required this.drawerOpenCount,
    required this.isActive,
  });

  // Convert Firestore document to CustodyReport instance
  factory CustodyReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustodyReport(
      id: doc.id,
      openingTime: data['opening_time'] as Timestamp,
      closingTime: data['closingTime'] as Timestamp,
      openingAmount: (data['opening_amount'] ?? 0.0).toDouble(),
      cashPaymentsNet: (data['cash_payments_net'] ?? 0.0).toDouble(),
      totalPayIns: (data['total_pay_ins'] ?? 0.0).toDouble(),
      totalPayOuts: (data['total_pay_outs'] ?? 0.0).toDouble(),
      cashDrop: (data['cash_drop'] ?? 0.0).toDouble(),
      closingAmount: (data['closing_amount'] ?? 0.0).toDouble(),
      expectedDrawerMoney: (data['expected_drawer_money'] ?? 0.0).toDouble(),
      difference: (data['difference'] ?? 0.0).toDouble(),
      drawerOpenCount: (data['drawer_open_count'] ?? 0).toInt(),
      isActive: data['isActive'] as bool,
    );
  }

  // Convert CustodyReport instance to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'opening_time': openingTime,
      'closingTime': closingTime,
      'opening_amount': openingAmount,
      'cash_payments_net': cashPaymentsNet,
      'total_pay_ins': totalPayIns,
      'total_pay_outs': totalPayOuts,
      'cash_drop': cashDrop,
      'closing_amount': closingAmount,
      'expected_drawer_money': expectedDrawerMoney,
      'difference': difference,
      'drawer_open_count': drawerOpenCount,
      'isActive': isActive,
    };
  }
}
