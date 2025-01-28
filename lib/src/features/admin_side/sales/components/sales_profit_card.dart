import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SalesProfitCard extends StatelessWidget {
  const SalesProfitCard({
    super.key,
    required this.totalProfit,
    required this.totalCostPrice,
    required this.totalTaxAmount,
    required this.totalDiscountAmount,
    required this.percentage,
    required this.percentageTitle,
    required this.increase,
    required this.loading,
  });

  final String totalProfit;
  final String totalCostPrice;
  final String totalTaxAmount;
  final String totalDiscountAmount;
  final String percentage;
  final String percentageTitle;
  final bool increase;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200, //New
                    blurRadius: 10,
                  )
                ],
                color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black),
                    width: 140,
                    height: 45,
                    child: const SizedBox(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            width: 90,
                            height: 20,
                            child: const SizedBox(),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            width: 120,
                            height: 30,
                            child: const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            width: 90,
                            height: 20,
                            child: const SizedBox(),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            width: 120,
                            height: 30,
                            child: const SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        width: 40,
                        height: 20,
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        width: 60,
                        height: 20,
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        width: 160,
                        height: 20,
                        child: const SizedBox(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        : Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200, //New
                    blurRadius: 10,
                  )
                ],
                color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'salesProfit'.tr,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 24,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'totalProfit'.tr,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AutoSizeText(
                          totalProfit,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'costPrice'.tr,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AutoSizeText(
                          totalCostPrice,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'discountAmount'.tr,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AutoSizeText(
                          totalDiscountAmount,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'taxAmount'.tr,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AutoSizeText(
                          totalTaxAmount,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 22,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      increase
                          ? FontAwesomeIcons.chartLine
                          : Icons.show_chart_rounded,
                      color: increase ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      percentage,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: increase ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      percentageTitle,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
