import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class GeneralReportsCard extends StatelessWidget {
  const GeneralReportsCard({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.amount,
    required this.subtitle,
    required this.percentage,
    required this.percentageTitle,
    required this.increase,
    required this.loading,
  });
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String amount;
  final String subtitle;
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
                color: backgroundColor),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade200,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: iconBackgroundColor),
                        width: 60,
                        height: 50,
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: iconBackgroundColor),
                            width: 140,
                            height: 30,
                            child: const SizedBox(),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: iconBackgroundColor),
                            width: 90,
                            height: 20,
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
                            color: iconBackgroundColor),
                        width: 40,
                        height: 20,
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: iconBackgroundColor),
                        width: 60,
                        height: 20,
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: iconBackgroundColor),
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
                color: backgroundColor),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: iconBackgroundColor),
                      child: Icon(icon, size: 32, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amount,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 28,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
