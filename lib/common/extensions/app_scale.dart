import 'package:flutter/material.dart';

class AppScale {
  late final double _screenWidth;
  bool initialized = false;

  void init(BuildContext context) {
    if (!initialized) {
      _screenWidth = MediaQuery.of(context).size.width;
      initialized = true;
    }
  }

  double get screenWidth => _screenWidth;

  double get textScaleFactor => screenWidth < 360 ? 0.7 : 1.0;

  double get iconSize => screenWidth < 360 ? 16.0 : 24.0;
}
