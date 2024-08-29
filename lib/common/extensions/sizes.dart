// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class Sizes {
  Sizes._();

  double _width = 0;
  double _height = 0;

  static const Size _designSize = Size(414, 896);

  // base of singleton
  static final _instance = Sizes._();

  // singleton constructor
  factory Sizes() => _instance;

  double get width => _width;

  double get height => _height;

  static void init(
    BuildContext context, {
    Size degignSize = _designSize,
  }) {
    final deviceData = MediaQuery.maybeOf(context);

    final deviceSize = deviceData?.size ?? _designSize;

    _instance._width = deviceSize.width;
    _instance._height = deviceSize.height;
  }
}

extension SizesExt on num {
  double get w {
    return (this * Sizes._instance._width) / Sizes._designSize.width;
  }

  double get h {
    return (this * Sizes._instance._height) / Sizes._designSize.height;
  }
}
