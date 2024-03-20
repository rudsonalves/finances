import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/colors/app_colors.dart';
import '../constants/themes/icons/fontello_icons.dart';
import 'custom_bottom_app_bar_item.dart';

class CustomBottomNavigatorBar extends StatefulWidget {
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
  State<CustomBottomNavigatorBar> createState() =>
      _CustomBottomNavigatorBarState();
}

class _CustomBottomNavigatorBarState extends State<CustomBottomNavigatorBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color selecteColor = colorScheme.primary;
    Color unselecteColor = AppColors.unselectedText;
    final locale = AppLocalizations.of(context)!;

    return BottomAppBar(
      shape: (widget.floatAppButton) ? const CircularNotchedRectangle() : null,
      child: Column(
        children: [
          IconTheme(
            data: const IconThemeData(
              size: 32,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBottomAppBarItem(
                  tooltip: locale.transPageTitle,
                  changePage: widget.changePage,
                  icon: widget.page == 0 ? Icons.home : Icons.home_outlined,
                  color: widget.page == 0 ? selecteColor : unselecteColor,
                  index: 0,
                ),
                CustomBottomAppBarItem(
                  tooltip: locale.accountPageTitle,
                  changePage: widget.changePage,
                  icon: widget.page == 1
                      ? Icons.account_balance
                      : Icons.account_balance_outlined,
                  color: widget.page == 1 ? selecteColor : unselecteColor,
                  index: 1,
                ),
                CustomBottomAppBarItem(
                  tooltip: locale.budgetPageTitle,
                  changePage: widget.changePage,
                  icon: widget.page == 2
                      ? FontelloIcons.budget_page
                      : FontelloIcons.budget_outlined_ori,
                  color: widget.page == 2 ? selecteColor : unselecteColor,
                  index: 2,
                ),
                CustomBottomAppBarItem(
                  tooltip: locale.statisticsPageTitle,
                  changePage: widget.changePage,
                  icon: widget.page == 3
                      ? Icons.assessment
                      : Icons.assessment_outlined,
                  color: widget.page == 3 ? selecteColor : unselecteColor,
                  index: 3,
                ),
                CustomBottomAppBarItem(
                  tooltip: locale.statisticsPageTitle,
                  changePage: widget.changePage,
                  icon: widget.page == 4
                      ? FontelloIcons.ofx_archive
                      : FontelloIcons.ofx_archive_off,
                  color: widget.page == 4 ? selecteColor : unselecteColor,
                  index: 4,
                ),
                if (widget.floatAppButton) const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
