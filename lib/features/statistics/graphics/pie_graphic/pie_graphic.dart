import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/category_chart_model.dart';
import 'widget/badge_pie.dart';

class PieGraphic extends StatefulWidget {
  final double centerSpaceRadius;
  final double sectionsSpace;
  final List<CategoryChartModel> chartData;

  const PieGraphic({
    super.key,
    this.centerSpaceRadius = 0.0,
    this.sectionsSpace = 0.0,
    required this.chartData,
  });

  @override
  State<PieGraphic> createState() => _PieGraphicState();
}

class _PieGraphicState extends State<PieGraphic> {
  int touchedIndex = 0;

  PieChartSectionData pieCharData({
    required double value,
    required String title,
    required Color color,
    required double radius,
    required TextStyle textStyle,
    required double widgetSize,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: textStyle,
      badgeWidget: BadgePie(
        icon: icon,
        size: widgetSize,
        borderColor: colorScheme.scrim,
      ),
      badgePositionPercentageOffset: .98,
    );
  }

  List<PieChartSectionData> showingSections(int touchedIndex) {
    return List.generate(
      widget.chartData.length,
      (index) {
        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 16.0 : 12.0;
        final radius = isTouched ? 110.0 : 100.0;
        final widgetSize = isTouched ? 40.0 : 35.0;
        final shadows = [
          const Shadow(
            color: Colors.black,
            blurRadius: 2,
          ),
        ];

        final textStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          shadows: shadows,
        );

        return pieCharData(
          value: widget.chartData[index].value,
          color: widget.chartData[index].color,
          icon: widget.chartData[index].icon,
          title: widget.chartData[index].name,
          radius: radius,
          textStyle: textStyle,
          widgetSize: widgetSize,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback:
              (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: widget.sectionsSpace,
        centerSpaceRadius: widget.centerSpaceRadius,
        sections: showingSections(touchedIndex),
      ),
    );
  }
}
