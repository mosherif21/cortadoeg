import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../general/common_widgets/ripple_circle.dart';

class OrderWidget extends StatelessWidget {
  const OrderWidget(
      {super.key,
      required this.orderModel,
      required this.onTap,
      required this.isChosen});
  final OrderModel orderModel;
  final Function onTap;
  final bool isChosen;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isChosen ? Colors.grey.shade300 : Colors.grey.shade200,
            blurRadius: isChosen ? 15 : 5,
          )
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(10),
          splashFactory: InkSparkle.splashFactory,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'orderNumber'.trParams(
                          {'number': orderModel.orderNumber.toString()}),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    RippleCircle(
                      color: orderModel.status == OrderStatus.active
                          ? Colors.green
                          : orderModel.status == OrderStatus.complete
                              ? Colors.grey
                              : orderModel.status == OrderStatus.canceled
                                  ? Colors.red
                                  : Colors.amber,
                      innerRadius: 6,
                      outerRadius: 10,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      orderModel.status == OrderStatus.active
                          ? 'active'.tr
                          : orderModel.status == OrderStatus.complete
                              ? 'completed'.tr
                              : orderModel.status == OrderStatus.canceled
                                  ? 'canceled'.tr
                                  : 'returned'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: orderModel.timestamp.toDate().isBefore(
                                  DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      0,
                                      0,
                                      0))
                              ? 100
                              : 130),
                      child: Text(
                        formatOrderDetails(
                            isTakeaway: orderModel.isTakeaway,
                            tablesNo: orderModel.tableNumbers),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      getOrderTime(orderModel.timestamp.toDate()),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (orderModel.timestamp.toDate().isBefore(DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        0,
                        0,
                        0)))
                      Text(
                        ' ${getOrderDate(orderModel.timestamp.toDate())}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getOrderTotal() {
    final double subtotal = orderModel.items
        .fold(0, (addition, item) => addition + item.price * item.quantity);

    double discountAmount = 0.0;
    if (orderModel.discountType != null && orderModel.discountValue != null) {
      if (orderModel.discountType == 'percentage') {
        discountAmount = subtotal * (orderModel.discountValue! / 100);
      } else if (orderModel.discountType == 'value') {
        discountAmount = orderModel.discountValue!;
      }
    }

    final taxableAmount =
        (subtotal - discountAmount) < 0 ? 0 : (subtotal - discountAmount);
    final orderTax = taxableAmount * (0 / 100);
    final orderTotal = roundToNearestHalfOrWhole(taxableAmount + orderTax);

    return orderTotal == 0 ? '\$0' : '\$${orderTotal.toString()}';
  }

  String formatOrderDetails({
    required bool isTakeaway,
    required List<int>? tablesNo,
  }) {
    String locationStr;
    if (isTakeaway) {
      locationStr = 'takeaway'.tr;
    } else {
      locationStr = '${'table'.tr} ';
      locationStr += tablesNo!.map((tableNo) {
        return 'tableNumberD'.trParams({'number': tableNo.toString()});
      }).join(', ');
    }
    return locationStr;
  }
}

class LoadingOrderWidget extends StatelessWidget {
  const LoadingOrderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                const RippleCircle(
                  color: Colors.black,
                  innerRadius: 6,
                  outerRadius: 10,
                ),
                const SizedBox(width: 5),
                Container(
                  width: 40,
                  height: 15,
                  color: Colors.black,
                ),
                const Spacer(),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 15,
                  color: Colors.black,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 15,
                  color: Colors.black,
                ),
                const SizedBox(width: 5),
                Container(
                  width: 30,
                  height: 15,
                  color: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
