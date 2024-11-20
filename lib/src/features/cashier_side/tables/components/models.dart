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

List<TableModel> tablesDataExample = [
  TableModel(
      tableId: '12342411',
      number: 1,
      status: TableStatus.available,
      currentOrderId: null),
  TableModel(
      tableId: '12342412',
      number: 2,
      status: TableStatus.available,
      currentOrderId: null),
  TableModel(
      tableId: '12342413',
      number: 3,
      status: TableStatus.available,
      currentOrderId: null),
  TableModel(
      tableId: '12342414',
      number: 4,
      status: TableStatus.occupied,
      currentOrderId: '30123'),
  TableModel(
      tableId: '12342415',
      number: 5,
      status: TableStatus.unavailable,
      currentOrderId: null),
  TableModel(
      tableId: '12342416',
      number: 6,
      status: TableStatus.available,
      currentOrderId: null),
  TableModel(
      tableId: '12342417',
      number: 7,
      status: TableStatus.occupied,
      currentOrderId: '30124'),
  TableModel(
      tableId: '12342418',
      number: 8,
      status: TableStatus.occupied,
      currentOrderId: '30125'),
  TableModel(
      tableId: '12342419',
      number: 9,
      status: TableStatus.occupied,
      currentOrderId: '30126'),
  TableModel(
      tableId: '12342410',
      number: 10,
      status: TableStatus.available,
      currentOrderId: null),
];
