import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/sales_screen.dart';

class SalesAnalyticsCard extends StatelessWidget {
  const SalesAnalyticsCard({
    super.key,
    required this.completePercent,
    required this.returnPercent,
    required this.canceledPercent,
  });
  final double completePercent;
  final double returnPercent;
  final double canceledPercent;
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
            'salesAnalytics'.tr,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 24,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w800,
            ),
          ),
          AspectRatio(
            aspectRatio: 1.3,
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
                        sections: completePercent == 0.0 &&
                                returnPercent == 0.0 &&
                                canceledPercent == 0.0
                            ? showingSections(
                                touchedIndex.value, 100.0, 0.0, 0.0)
                            : showingSections(
                                touchedIndex.value,
                                completePercent,
                                returnPercent,
                                canceledPercent),
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
                      color: Colors.green,
                      text: 'completed'.tr,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: Colors.amber,
                      text: 'returned'.tr,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: Colors.red,
                      text: 'canceled'.tr,
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

  List<PieChartSectionData> showingSections(int touchedIndex,
      double completedPercent, double returnedPercent, double canceledPercent) {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 55.0 : 45.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: completedPercent,
            title: '$completedPercent%',
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
            value: returnedPercent,
            title: '$returnedPercent%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red,
            value: canceledPercent,
            title: '$canceledPercent%',
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
