import 'package:flutter/material.dart';

class AppScale {
  late double _screenWidth;
  bool initialized = false;

  void init(BuildContext context) {
    _screenWidth = MediaQuery.sizeOf(context).width;
    initialized = true;
  }

  double get screenWidth => _screenWidth;

  double get textScaleFactor => screenWidth < 360 ? 0.7 : 1.0;

  double get iconSize => screenWidth < 360 ? 16.0 : 24.0;
}
