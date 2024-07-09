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

import '../../common/extensions/sizes.dart';
import '../../common/constants/themes/app_colors.dart';

class AppTopBorder extends StatelessWidget {
  const AppTopBorder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: WaveClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.getMediumColorsGradient(context),
            ),
          ),
          height: 143.h,
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = 40;
    var path = Path();
    path.lineTo(0, size.height - height / 2);
    var path0 = Offset(size.width * 0.25, size.height);
    var path1 = Offset(size.width * .5, size.height - height / 2);
    var path2 = Offset(size.width * .75, size.height - height);
    var path3 = Offset(size.width, size.height - height / 2);
    path.quadraticBezierTo(path0.dx, path0.dy, path1.dx, path1.dy);
    path.quadraticBezierTo(path2.dx, path2.dy, path3.dx, path3.dy);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
