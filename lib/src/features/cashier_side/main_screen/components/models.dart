import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  sale,
  completeSale,
  reopenSale,
  returnSale,
  payIn,
  payOut,
  cashDrop,
}

class CustodyTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final Timestamp timestamp;

  CustodyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

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
  final String id;
  final Timestamp openingTime;
  final Timestamp closingTime;
  final double openingAmount;
  final double cashPaymentsNet;
  final double totalPayIns;
  final double totalPayOuts;
  final double cashDrop;
  double closingAmount;
  double expectedDrawerMoney;
  double difference;
  final int drawerOpenCount;
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
