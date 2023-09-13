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
