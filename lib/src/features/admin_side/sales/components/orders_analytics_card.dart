import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/sales_screen.dart';

class OrdersAnalyticsCard extends StatelessWidget {
  const OrdersAnalyticsCard({
    super.key,
    required this.dineInPercent,
    required this.takeawayPercent,
    required this.isPhone,
  });
  final double dineInPercent;
  final double takeawayPercent;
  final bool isPhone;
  @override
  Widget build(BuildContext context) {
    final RxInt touchedIndex = RxInt(-1);
    return Container(
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
            'ordersAnalytics'.tr,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 24,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w800,
            ),
          ),
          AspectRatio(
            aspectRatio: isPhone ? 1.3 : 2.2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Obx(
                    () => PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex.value = -1;
                              return;
                            }
                            touchedIndex.value = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        sections: dineInPercent == 0.0 && takeawayPercent == 0.0
                            ? showingSections(touchedIndex.value, 100.0, 0.0)
                            : showingSections(touchedIndex.value, dineInPercent,
                                takeawayPercent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Indicator(
                      color: Colors.black,
                      text: 'dineIn'.tr,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: Colors.amber,
                      text: 'takeaway'.tr,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 28,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      int touchedIndex, double dineInPercent, double takeawayPercent) {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 55.0 : 45.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.black,
            value: dineInPercent,
            title: '$dineInPercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.amber,
            value: takeawayPercent,
            title: '$takeawayPercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
