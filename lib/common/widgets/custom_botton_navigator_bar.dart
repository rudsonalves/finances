import 'package:flutter/material.dart';

class CustomBottomNavigatorBar extends StatelessWidget {
  final bool floatAppButton;
  final void Function(int) changePage;
  final int page;

  const CustomBottomNavigatorBar({
    super.key,
    required this.floatAppButton,
    required this.changePage,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color selecteColor = colorScheme.primary;
    Color unselecteColor = colorScheme.outlineVariant;

    return BottomAppBar(
      shape: (floatAppButton) ? const CircularNotchedRectangle() : null,
      child: IconTheme(
        data: const IconThemeData(
          size: 32,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBottomAppBarItem(
              changePage: changePage,
              icon: page == 0 ? Icons.home : Icons.home_outlined,
              color: page == 0 ? selecteColor : unselecteColor,
              index: 0,
            ),
            CustomBottomAppBarItem(
              changePage: changePage,
              icon: page == 1 ? Icons.assessment : Icons.assessment_outlined,
              color: page == 1 ? selecteColor : unselecteColor,
              index: 1,
            ),
            if (floatAppButton) const SizedBox(width: 40),
            CustomBottomAppBarItem(
              changePage: changePage,
              icon: page == 2
                  ? Icons.account_balance
                  : Icons.account_balance_outlined,
              color: page == 2 ? selecteColor : unselecteColor,
              index: 2,
            ),
            CustomBottomAppBarItem(
              changePage: changePage,
              icon: page == 3 ? Icons.settings : Icons.settings_outlined,
              color: page == 3 ? selecteColor : unselecteColor,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomAppBarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int index;
  final void Function(int) changePage;

  const CustomBottomAppBarItem({
    super.key,
    required this.changePage,
    required this.icon,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
