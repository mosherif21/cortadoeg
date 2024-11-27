import '../../../../constants/enums.dart';

class TableModel {
  final int number;
  final TableStatus status;
  final String? currentOrderId;
  final String tableId;

  TableModel({
    required this.number,
    required this.status,
    required this.tableId,
    this.currentOrderId,
  });

  factory TableModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TableModel(
      tableId: id,
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
