import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'model/graphic_line_data.dart';

class LineGraphic extends StatelessWidget {
  final Color fontColor;
  final List<GraphicLineData> data;
  final List<String> xLabels;
  final bool showGrid;
  final bool drawHorizontalLine;
  final bool drawVerticalLine;
  final bool isCurved;
  final bool showDots;
  final bool areaChart;

  const LineGraphic({
    super.key,
    required this.fontColor,
    required this.data,
    required this.xLabels,
    this.showGrid = true,
    this.drawHorizontalLine = true,
    this.drawVerticalLine = true,
    this.isCurved = true,
    this.showDots = false,
    this.areaChart = false,
  });

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 14,
      // color: fontColor,
    );

    int index = value.toInt();

    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          index % 2 == 0 ? xLabels[index] : '',
          style: style,
        ),
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: fontColor,
    );

    String text;
    switch (value.toInt()) {
      case 2:
        text = '20k';
        break;
      case 4:
        text = '40k';
        break;
      case 6:
        text = '60k';
        break;
      default:
        return Container();
    }

    Widget label = Text(
      text,
      style: style,
      textAlign: TextAlign.left,
    );

    return label;
  }

  (double minY, double maxY) calculateYScale() {
    double maxY = 0.0;
    double minY = 0.0;

    for (final GraphicLineData graphicData in data) {
      for (final FlSpot point in graphicData.data) {
        if (maxY == 0) {
          minY = point.y;
          maxY = point.y;
          continue;
        }
        if (maxY < point.y) {
          maxY = point.y;
          continue;
        }
        if (minY > point.y) {
          minY = point.y;
        }
      }
    }

    maxY = (maxY > 0 ? maxY.ceil() : -(-maxY).round()).toDouble();
    minY = (minY > 0 ? minY.toInt() : -(-minY).ceil()).toDouble();

    double minScale = 0.0;
    double maxScale = 0.0;

    if (maxY != 0) {
      int orderMax = (log(maxY.abs()) / ln10).floor();
      double orderValueMax = pow(10, orderMax).toDouble();
      int scaleMax = (maxY / orderValueMax).round();

      maxScale = (scaleMax * orderValueMax).toDouble();
    }

    if (minY != 0) {
      int orderMin = (log(minY.abs()) / ln10).floor();
      double orderValueMin = pow(10, orderMin).toDouble();
      int scaleMin = (minY / orderValueMin).round();

      minScale = (scaleMin * orderValueMin).toDouble();
    }

    if (maxScale > 0) {
      final interval = maxScale / 10;
      while (maxScale < maxY) {
        maxScale += interval;
      }
    }

    // print("orderMaxY: $orderValueMax");
    // print("orderMinY: $orderValueMin");

    print('minY: $minY maxY: $maxY ');
    print('Scales: min: $minScale, max: $maxScale');

    return (minScale, maxScale);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    double minY;
    double maxY;

    (minY, maxY) = calculateYScale();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: showGrid,
          drawHorizontalLine: drawHorizontalLine,
          // horizontalInterval: 2,
          drawVerticalLine: drawVerticalLine,
          // verticalInterval: 2,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // interval: 1,
              // getTitlesWidget: leftTitleWidgets,
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colorScheme.primary),
        ),
        minX: 0,
        maxX: 11,
        minY: minY,
        maxY: maxY,
        lineBarsData: List<LineChartBarData>.generate(
          data.length,
          (index) => LineChartBarData(
            spots: data[index].data,
            isCurved: isCurved,
            color: data[index].color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: showDots,
            ),
            belowBarData: BarAreaData(
              show: areaChart,
              color: data[index].color.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
