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
