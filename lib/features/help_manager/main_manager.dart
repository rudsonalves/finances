import 'package:finances/features/help_manager/pages/introduction_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_button_styles.dart';
import '../../common/widgets/markdown_rich_text.dart';
import 'pages/accounts_delete_help.dart';
import 'pages/accounts_edit_help.dart';
import 'pages/accounts_help.dart';
import 'pages/budget_set_help.dart';
import 'pages/categories_budget_help.dart';
import 'pages/categories_edit_help.dart';
import 'pages/categories_help.dart';
import 'pages/icons_color_help.dart';
import 'pages/icons_selection_help.dart';
import 'pages/page_model.dart';
import 'pages/presentation_help.dart';
import 'pages/statistics_card.dart';
import 'pages/statistics_help.dart';
import 'pages/statistics_menu.dart';
import 'pages/statistics_move_help.dart';
import 'pages/transactions_add_help.dart';
import 'pages/transactions_card_help.dart';
import 'pages/transactions_edit_help.dart';
import 'pages/transactions_help.dart';

class StatusButtons {
  final bool _previus;
  final bool _close;
  final bool _next;

  StatusButtons(this._previus, this._close, this._next);

  bool get previus => _previus;
  bool get close => _close;
  bool get next => _next;
}

enum HelpCommand {
  previous,
  close,
  next,
}

const introductionHelp = 0;
const transactionsHelp = 2;
const newTransactionsHelp = 5;
const accountsHelp = 6;
const iconsSelectionsHelp = 9;
const categoriesHelp = 11;
const budgetSetHelp = 14;
const statisticsHelp = 15;

Future<void> managerTutorial(BuildContext context, [int index = 0]) async {
  StatusButtons buttons = StatusButtons(false, true, true);
  final Color primary = Theme.of(context).colorScheme.primary;
  final locale = AppLocalizations.of(context)!;

  final List<PageModel> pages = [
    IntroductionHelp.create(locale, primary), // 0
    PresentationHelp.create(locale, primary), // 1
    TransactionsHelp.create(locale, primary), // 2
    TransactionsCardHelp.create(locale, primary), // 3
    TransactionsEditHelp.create(locale, primary), // 4
    TransactionsAddHelp.create(locale, primary), // 5
    AccountsHelp.create(locale, primary), // 6
    AccountsEditHelp.create(locale, primary), // 7
    AccountsDeleteHelp.create(locale, primary), // 8
    IconsSelectionsHelp.create(locale, primary), // 9
    IconsColorHelp.create(locale, primary), // 10
    CategoriesHelp.create(locale, primary), // 11
    CategoriesEditHelp.create(locale, primary), // 12
    CategoriesBudgetHelp.create(locale, primary), // 13
    BudgetSetHelp.create(locale, primary), // 14
    StatisticsHelp.create(locale, primary), // 15
    StatisticsMoveHelp.create(locale, primary), // 16
    StatisticsCardHelp.create(locale, primary), // 17
    StatisticsMenuHelp.create(locale, primary), // 18
  ];

  HelpCommand? command = HelpCommand.next;

  while (command != HelpCommand.close) {
    if (index == 0) {
      buttons = StatusButtons(false, true, true);
    } else if (index == pages.length - 1) {
      buttons = StatusButtons(true, true, false);
    } else {
      buttons = StatusButtons(true, true, true);
    }

    command = await showDialog(
      context: context,
      builder: (context) => MainHelpManager(
        page: pages[index],
        buttons: buttons,
      ),
    );

    if (command != null) {
      switch (command) {
        case HelpCommand.previous:
          index = index > 0 ? index - 1 : index;
        case HelpCommand.close:
          break;
        case HelpCommand.next:
          index = index < pages.length - 1 ? index + 1 : index;
      }
    } else {
      break;
    }
  }
}

class MainHelpManager extends StatelessWidget {
  final PageModel page;
  final StatusButtons buttons;

  const MainHelpManager({
    super.key,
    required this.page,
    required this.buttons,
  });

  List<Widget> generateText({
    required List<Object> messages,
    required double height,
    required Color color,
  }) {
    List<Widget> widgetsList = [];

    for (final item in messages) {
      if (item is String) {
        widgetsList.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: height / 2),
            child: MarkdownRichText.richText(item, color: color),
          ),
        );
      } else if (item is List<Object>) {
        final alignment = item.length != 1
            ? MainAxisAlignment.start
            : MainAxisAlignment.center;

        final rowChildren = item.map<Widget>((subItem) {
          if (subItem is String) {
            return Expanded(
              child: MarkdownRichText.richText(subItem, color: color),
            );
          } else if (subItem is Widget) {
            return subItem;
          }
          return const SizedBox.shrink();
        }).toList();
        widgetsList.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: height),
            child: Row(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        );
      }
    }

    return widgetsList;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SimpleDialog(
      title: Text(
        page.title,
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.all(16),
      children: [
        ...generateText(
          messages: page.messages,
          height: 8,
          color: primary,
        ),
        const SizedBox(height: 6),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton.filled(
              onPressed: buttons._previus
                  ? () => Navigator.of(context).pop(HelpCommand.previous)
                  : null,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            ElevatedButton(
              onPressed: buttons.close
                  ? () => Navigator.of(context).pop(HelpCommand.close)
                  : null,
              style: AppButtonStyles.primaryButtonColor(context),
              child: const Text('Close'),
            ),
            IconButton.filled(
              onPressed: buttons.next
                  ? () => Navigator.of(context).pop(HelpCommand.next)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ],
    );
  }
}
