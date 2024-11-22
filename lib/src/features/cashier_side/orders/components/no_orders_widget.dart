import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../constants/enums.dart';

class NoOrdersWidget extends StatelessWidget {
  const NoOrdersWidget({super.key, this.status});
  final OrderStatus? status;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                kNoOrdersAnim,
                fit: BoxFit.contain,
                height: screenHeight * 0.5,
              ),
              AutoSizeText(
                status == null
                    ? 'noActiveOrdersTitle'.tr
                    : getNoOrdersBody(status!),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
              const SizedBox(height: 5.0),
              AutoSizeText(
                status == null
                    ? 'noActiveOrdersBody'.tr
                    : getNoOrdersTitle(status!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                maxLines: 2,
              ),
            ],
          )),
    );
  }

  String getNoOrdersTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'noActiveOrdersTitle'.tr;
      case OrderStatus.complete:
        return 'noCompletedOrdersTitle'.tr;
      case OrderStatus.returned:
        return 'noReturnedOrdersTitle'.tr;
      case OrderStatus.canceled:
        return 'noCanceledOrdersTitle'.tr;
      default:
        return 'noOrdersTitle'.tr;
    }
  }

  String getNoOrdersBody(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'noActiveOrdersBody'.tr;
      case OrderStatus.complete:
        return 'noCompletedOrdersBody'.tr;
      case OrderStatus.returned:
        return 'noReturnedOrdersBody'.tr;
      case OrderStatus.canceled:
        return 'noCanceledOrdersBody'.tr;
      default:
        return 'noOrdersBody'.tr;
    }
  }
}
