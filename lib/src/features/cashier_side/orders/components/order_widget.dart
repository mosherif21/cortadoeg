import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  const OrderWidget({super.key, required this.orderModel});
  final OrderModel orderModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300, //New
            blurRadius: 5.0,
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Text(orderModel.orderId),
          Text(orderModel.timestamp.toDate().toString()),
        ],
      ),
    );
  }
}
