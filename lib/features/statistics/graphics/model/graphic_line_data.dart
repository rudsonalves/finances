// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphicLineData {
  final List<FlSpot> data;
  final String name;
  final Color color;

  GraphicLineData({
    required this.data,
    required this.name,
    required this.color,
  });
}
