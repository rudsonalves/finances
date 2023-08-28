import 'package:flutter/material.dart';

import '../constants/themes/colors/custom_color.g.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget title;
  final List<Widget>? actions;
  final bool enableColor;
  final bool? centerTitle;

  const CustomAppBar({
    super.key,
    this.leading,
    required this.title,
    this.actions,
    this.enableColor = true,
    this.centerTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      foregroundColor:
          enableColor ? colorScheme.onPrimary : colorScheme.tertiary,
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      flexibleSpace: enableColor
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context)
                        .extension<CustomColors>()!
                        .sourceMediumprimary!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          : null,
      leading: leading,
      title: title,
      actions: actions,
    );
  }
}
