import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/colors/custom_colors.dart';
import '../constants/themes/icons/fontello_icons.dart';
import 'custom_bottom_app_bar_item.dart';

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
    Color unselecteColor = CustomColors.unselectedText;
    final locale = AppLocalizations.of(context)!;

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
              tooltip: locale.transPageTitle,
              changePage: changePage,
              icon: page == 0 ? Icons.home : Icons.home_outlined,
              color: page == 0 ? selecteColor : unselecteColor,
              index: 0,
            ),
            CustomBottomAppBarItem(
              tooltip: locale.statisticsPageTitle,
              changePage: changePage,
              icon: page == 1 ? Icons.assessment : Icons.assessment_outlined,
              color: page == 1 ? selecteColor : unselecteColor,
              index: 1,
            ),
            if (floatAppButton) const SizedBox(width: 40),
            CustomBottomAppBarItem(
              tooltip: locale.accountPageTitle,
              changePage: changePage,
              icon: page == 2
                  ? Icons.account_balance
                  : Icons.account_balance_outlined,
              color: page == 2 ? selecteColor : unselecteColor,
              index: 2,
            ),
            CustomBottomAppBarItem(
              tooltip: locale.budgetPageTitle,
              changePage: changePage,
              icon: page == 3
                  ? FontelloIcons.budgetOutlined2
                  : FontelloIcons.budget2,
              color: page == 3 ? selecteColor : unselecteColor,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }
}
