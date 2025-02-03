import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/enums.dart';
import '../../../../general/common_widgets/back_button.dart';
import '../../../../general/common_widgets/icon_text_elevated_button.dart';
import '../../../../general/common_widgets/section_divider.dart';
import '../../../../general/general_functions.dart';
import '../components/models.dart';
import '../components/orders_screen_item_widget.dart';

class OrderDetailsScreenPhone extends StatelessWidget {
  const OrderDetailsScreenPhone(
      {super.key,
      required this.orderModel,
      required this.controller,
      required this.adminView});
  final OrderModel orderModel;
  final dynamic controller;
  final bool adminView;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: const RegularBackButton(padding: 0),
        centerTitle: true,
        title: AutoSizeText(
          'orderDetails'.tr,
          maxLines: 2,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'orderNumber'
                      .trParams({'number': orderModel.orderNumber.toString()}),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 22),
                ),
                const SizedBox(width: 5),
                Text(
                  getOrderTime(orderModel.timestamp.toDate()),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                orderModel.customerName ?? 'guest'.tr,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const SectionDivider(),
            const SizedBox(height: 5),
            Expanded(
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: orderModel.items.length,
                  itemBuilder: (context, index) {
                    return OrdersScreenItemWidget(
                        orderItemModel: orderModel.items[index]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'subtotal'.tr,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'EGP ${orderModel.subtotalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'discountSales'.tr,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '-EGP ${orderModel.discountAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'totalSalesTax'.tr,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'EGP ${orderModel.taxTotalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'total'.tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'EGP ${orderModel.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!adminView)
              orderModel.status == OrderStatus.complete
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: IconTextElevatedButton(
                                buttonColor: Colors.amber,
                                textColor: Colors.white,
                                borderRadius: 10,
                                fontSize: 16,
                                elevation: 0,
                                icon: Icons.assignment_return,
                                iconColor: Colors.white,
                                text: 'return'.tr,
                                onClick: () => controller.returnOrderTap(
                                    isPhone: true,
                                    orderModel: orderModel,
                                    context: context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: IconTextElevatedButton(
                                buttonColor: Colors.deepOrange,
                                textColor: Colors.white,
                                borderRadius: 10,
                                elevation: 0,
                                fontSize: 16,
                                icon: Icons.refresh,
                                iconColor: Colors.white,
                                text: 'reopen'.tr,
                                onClick: () => controller.onReopenOrderTap(
                                    isPhone: true,
                                    context: context,
                                    aOrderModel: orderModel),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        IconTextElevatedButton(
                          buttonColor: Colors.green,
                          textColor: Colors.white,
                          borderRadius: 10,
                          elevation: 0,
                          fontSize: 16,
                          icon: Icons.print_outlined,
                          iconColor: Colors.white,
                          text: 'printInvoice'.tr,
                          onClick: () => controller.printOrderTap(
                              isPhone: true, orderModel: orderModel),
                        ),
                      ],
                    )
                  : orderModel.status == OrderStatus.returned
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: IconTextElevatedButton(
                                    buttonColor: Colors.grey,
                                    textColor: Colors.white,
                                    borderRadius: 10,
                                    elevation: 0,
                                    fontSize: 16,
                                    icon: Icons.check_circle,
                                    iconColor: Colors.white,
                                    text: 'complete'.tr,
                                    onClick: () => controller.completeOrderTap(
                                        isPhone: true, orderModel: orderModel),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: IconTextElevatedButton(
                                    buttonColor: Colors.deepOrange,
                                    textColor: Colors.white,
                                    borderRadius: 10,
                                    elevation: 0,
                                    fontSize: 16,
                                    icon: Icons.refresh,
                                    iconColor: Colors.white,
                                    text: 'reopen'.tr,
                                    onClick: () => controller.onReopenOrderTap(
                                        isPhone: true,
                                        context: context,
                                        aOrderModel: orderModel),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: IconTextElevatedButton(
                            buttonColor: Colors.deepOrange,
                            textColor: Colors.white,
                            borderRadius: 10,
                            elevation: 0,
                            fontSize: 16,
                            icon: Icons.refresh,
                            iconColor: Colors.white,
                            text: 'reopen'.tr,
                            onClick: () => controller.onReopenOrderTap(
                                isPhone: true,
                                context: context,
                                aOrderModel: orderModel),
                          ),
                        ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
