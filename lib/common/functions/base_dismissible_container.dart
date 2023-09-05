import 'package:flutter/material.dart';

Container baseDismissibleContainer(
  BuildContext context, {
  required AlignmentGeometry alignment,
  required Color color,
  required IconData icon,
  String? label,
  bool enable = true,
}) {
  List<Alignment> alignLeft = [
    Alignment.bottomLeft,
    Alignment.topLeft,
    Alignment.centerLeft
  ];

  final colorScheme = Theme.of(context).colorScheme;
  late Widget rowIcon;

  Color enableColor = colorScheme.shadow;
  Color disableColor = colorScheme.outlineVariant;

  if (label != null) {
    if (alignLeft.contains(alignment)) {
      rowIcon = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: enable ? enableColor : disableColor,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: enable ? enableColor : disableColor,
            ),
          ),
        ],
      );
    } else {
      rowIcon = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: enable ? enableColor : disableColor,
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            icon,
            color: enable ? enableColor : disableColor,
          ),
        ],
      );
    }
  } else {
    rowIcon = Icon(icon);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    alignment: alignment,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: rowIcon,
  );
}
