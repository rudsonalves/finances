import 'package:flutter/material.dart';

class CustomBottomAppBarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int index;
  final String? tooltip;
  final void Function(int) changePage;

  const CustomBottomAppBarItem({
    super.key,
    required this.changePage,
    required this.icon,
    required this.index,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        changePage(index);
      },
      icon: Icon(
        icon,
        color: color,
      ),
    );
  }
}
