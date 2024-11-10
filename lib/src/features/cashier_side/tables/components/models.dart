import '../../../../constants/enums.dart';

class TableModel {
  final int number;
  final TableStatus status;
  final String? currentOrderId;

  TableModel({
    required this.number,
    required this.status,
    this.currentOrderId,
  });

  factory TableModel.fromFirestore(Map<String, dynamic> data) {
    return TableModel(
      number: data['number'] ?? 0,
      status: TableStatus.values.byName(data['status']),
      currentOrderId: data['currentOrderId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'number': number,
      'status': status.name,
      'currentOrderId': currentOrderId,
    };
  }
}
