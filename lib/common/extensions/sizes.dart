import 'package:flutter/material.dart';

class Sizes {
  Sizes._();

  double _width = 0;
  double _height = 0;

  static const Size _defaultDesignSize = Size(414, 896);

  Size _designSize = _defaultDesignSize;

  // base of singleton
  static final _instance = Sizes._();

  // singleton constructor
  factory Sizes() => _instance;

  double get width => _width;

  double get height => _height;

  static void init(
    BuildContext context, {
    Size designSize = _defaultDesignSize,
  }) {
    final MediaQueryData? deviceData = MediaQuery.maybeOf(context);
    final Size deviceSize = deviceData?.size ?? designSize;

    _instance._width = deviceSize.width;
    _instance._height = deviceSize.height;
    _instance._designSize = designSize;
  }
}

extension SizesExt on num {
  double get w {
    return (this * Sizes._instance._width) / Sizes._instance._designSize.width;
  }

  double get h {
    return (this * Sizes._instance._height) /
        Sizes._instance._designSize.height;
  }
}
