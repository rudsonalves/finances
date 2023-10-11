import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_button_styles.dart';
import '../../common/widgets/markdown_rich_text.dart';
import 'index_help.dart';
import 'pages/accounts_delete_help.dart';
import 'pages/accounts_edit_help.dart';
import 'pages/accounts_help.dart';
import 'pages/budget_set_help.dart';
import 'pages/categories_budget_help.dart';
import 'pages/categories_edit_help.dart';
import 'pages/categories_help.dart';
import 'pages/icons_color_help.dart';
import 'pages/icons_selection_help.dart';
import 'model/page_model.dart';
import 'pages/introduction_help.dart';
import 'pages/presentation_help.dart';
import 'pages/statistics_card.dart';
import 'pages/statistics_help.dart';
import 'pages/statistics_menu.dart';
import 'pages/statistics_move_help.dart';
import 'pages/transactions_add_help.dart';
import 'pages/transactions_card_help.dart';
import 'pages/transactions_edit_help.dart';
import 'pages/transactions_future.dart';
import 'pages/transactions_help.dart';
import 'pages/transactions_lock.dart';

enum HelpCommand {
  previous,
  close,
  next,
  content,
  none,
}

class StatusButtons {
  final bool _previus;
  final bool _close;
  final bool _next;

  StatusButtons(this._previus, this._close, this._next);

  bool get previus => _previus;
  bool get close => _close;
  bool get next => _next;
}

const introductionHelp = 0;
const presentationHelp = 1;
const transactionsHelp = 2;
const transactionsCardHelp = 3;
const transactionsEditHelp = 4;
const transactionsAddHelp = 5;
const transactionsLockHelp = 6;
const transactionsFutureHelp = 7;
const accountsHelp = 8;
const accountsEditHelp = 9;
const accountsDeleteHelp = 10;
const iconsSelectionsHelp = 11;
const iconsColorHelp = 12;
const categoriesHelp = 13;
const categoriesEditHelp = 14;
const categoriesBudgetHelp = 15;
const budgetSetHelp = 16;
const statisticsHelp = 17;
const statisticsMoveHelp = 18;
const statisticsCardHelp = 19;
const statisticsMenuHelp = 20;
const lastPage = statisticsMenuHelp;

PageModel createPage(int index, AppLocalizations locale, Color color) {
  switch (index) {
    case introductionHelp:
      return IntroductionHelp.create(locale, color);
    case presentationHelp:
      return PresentationHelp.create(locale, color);
    case transactionsHelp:
      return TransactionsHelp.create(locale, color);
    case transactionsCardHelp:
      return TransactionsCardHelp.create(locale, color);
    case transactionsEditHelp:
      return TransactionsEditHelp.create(locale, color);
    case transactionsAddHelp:
      return TransactionsAddHelp.create(locale, color);
    case transactionsLockHelp:
      return TransactionsLockHelp.create(locale, color);
    case transactionsFutureHelp:
      return TransactionsFutureHelp.create(locale, color);
    case accountsHelp:
      return AccountsHelp.create(locale, color);
    case accountsEditHelp:
      return AccountsEditHelp.create(locale, color);
    case accountsDeleteHelp:
      return AccountsDeleteHelp.create(locale, color);
    case iconsSelectionsHelp:
      return IconsSelectionsHelp.create(locale, color);
    case iconsColorHelp:
      return IconsColorHelp.create(locale, color);
    case categoriesHelp:
      return CategoriesHelp.create(locale, color);
    case categoriesEditHelp:
      return CategoriesEditHelp.create(locale, color);
    case categoriesBudgetHelp:
      return CategoriesBudgetHelp.create(locale, color);
    case budgetSetHelp:
      return BudgetSetHelp.create(locale, color);
    case statisticsHelp:
      return StatisticsHelp.create(locale, color);
    case statisticsMoveHelp:
      return StatisticsMoveHelp.create(locale, color);
    case statisticsCardHelp:
      return StatisticsCardHelp.create(locale, color);
    // case statisticsMenuHelp:
    default:
      return StatisticsMenuHelp.create(locale, color);
  }
}

Future<void> managerTutorial(BuildContext context, [int index = 0]) async {
  StatusButtons buttons = StatusButtons(false, true, true);
  final Color primary = Theme.of(context).colorScheme.primary;
  final locale = AppLocalizations.of(context)!;

  HelpCommand? command = HelpCommand.next;

  while (command != HelpCommand.close) {
    if (index == 0) {
      buttons = StatusButtons(false, true, true);
    } else if (index == lastPage) {
      buttons = StatusButtons(true, true, false);
    } else {
      buttons = StatusButtons(true, true, true);
    }

    if (command == HelpCommand.content) {
      if (!context.mounted) return;
      final result = await showDialog(
        context: context,
        builder: (context) => const IndexHelp(),
      );
      if (result is HelpCommand) {
        command = result;
      } else {
        index = result as int;
        command = HelpCommand.none;
      }
    } else {
      if (!context.mounted) return;
      command = await showDialog(
        context: context,
        builder: (context) => MainHelpManager(
          page: createPage(index, locale, primary),
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
            index = index < lastPage ? index + 1 : index;
          case HelpCommand.content || HelpCommand.none:
            index = index;
        }
      } else {
        break;
      }
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

  double _calculateFontSize(String text) {
    const maxWidth = 200.0; // Ajuste a largura máxima conforme necessário
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 24.0), // Tamanho de fonte inicial
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: 1000);

    final width = textPainter.width;
    final scale = width > maxWidth ? maxWidth / width : 1.0;

    return 24.0 * scale;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fontSize = _calculateFontSize(page.title);
    final locale = AppLocalizations.of(context)!;

    return SimpleDialog(
      title: Row(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              page.title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () => Navigator.of(context).pop(HelpCommand.content),
              icon: Icon(
                Icons.list,
                color: primary,
              ))
        ],
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
            IconButton(
              onPressed: buttons._previus
                  ? () => Navigator.of(context).pop(HelpCommand.previous)
                  : null,
              icon: Icon(
                Icons.arrow_back_ios,
                color: primary,
              ),
            ),
            ElevatedButton(
              onPressed: buttons.close
                  ? () => Navigator.of(context).pop(HelpCommand.close)
                  : null,
              style: AppButtonStyles.primaryButtonColor(context),
              child: Text(locale.genericClose),
            ),
            IconButton(
              onPressed: buttons.next
                  ? () => Navigator.of(context).pop(HelpCommand.next)
                  : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
