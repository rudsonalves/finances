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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/widgets/markdown_rich_text.dart';
import 'index_help.dart';
import 'pages/accounts_delete_help.dart';
import 'pages/accounts_edit_help.dart';
import 'pages/accounts_help.dart';
import 'pages/backup_create_help.dart';
import 'pages/backup_restore_help.dart';
import 'pages/backup_restore_only_help.dart';
import 'pages/budget_set_help.dart';
import 'pages/categories_budget_help.dart';
import 'pages/categories_edit_help.dart';
import 'pages/categories_help.dart';
import 'pages/icons_color_help.dart';
import 'pages/icons_selection_help.dart';
import 'model/page_model.dart';
import 'pages/introduction_help.dart';
import 'pages/ofx_add_trans_help.dart';
import 'pages/ofx_auto_trans_help.dart';
import 'pages/ofx_delete_file.dart';
import 'pages/ofx_import_file_help.dart';
import 'pages/ofx_import_help.dart';
import 'pages/ofx_main_help.dart';
import 'pages/presentation_help.dart';
import 'pages/settings_help.dart';
import 'pages/statistics_card.dart';
import 'pages/statistics_help.dart';
import 'pages/statistics_menu.dart';
import 'pages/statistics_move_help.dart';
import 'pages/transactions_add_help.dart';
import 'pages/transactions_card_help.dart';
import 'pages/transactions_edit_help.dart';
import 'pages/transactions_filter_help.dart';
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

enum HelpTopics {
  introductionHelp,
  presentationHelp,
  transactionsHelp,
  transactionsCardHelp,
  transactionsEditHelp,
  transactionsAddHelp,
  transactionsLockHelp,
  transactionsFutureHelp,
  transactionsFilterHelp,
  ofxMainHelp,
  ofxImportHelp,
  ofxImportFileHelp,
  ofxAddTransHelp,
  ofxAutoTransHelp,
  ofxDeleteFileHelp,
  backupRestoreHelp,
  backupCreateHelp,
  backupRestoreOnlyHelp,
  accountsHelp,
  accountsEditHelp,
  accountsDeleteHelp,
  iconsSelectionsHelp,
  iconsColorHelp,
  categoriesHelp,
  categoriesEditHelp,
  categoriesBudgetHelp,
  budgetSetHelp,
  statisticsHelp,
  statisticsMoveHelp,
  statisticsCardHelp,
  statisticsMenuHelp,
  settingsHelp,
}

PageModel createPage(int index, AppLocalizations locale, Color color) {
  final help = HelpTopics.values[index];
  switch (help) {
    case HelpTopics.introductionHelp:
      return IntroductionHelp.create(locale, color);
    case HelpTopics.presentationHelp:
      return PresentationHelp.create(locale, color);
    case HelpTopics.transactionsHelp:
      return TransactionsHelp.create(locale, color);
    case HelpTopics.transactionsCardHelp:
      return TransactionsCardHelp.create(locale, color);
    case HelpTopics.transactionsEditHelp:
      return TransactionsEditHelp.create(locale, color);
    case HelpTopics.transactionsAddHelp:
      return TransactionsAddHelp.create(locale, color);
    case HelpTopics.transactionsLockHelp:
      return TransactionsLockHelp.create(locale, color);
    case HelpTopics.transactionsFutureHelp:
      return TransactionsFutureHelp.create(locale, color);
    case HelpTopics.transactionsFilterHelp:
      return TransactionsFilterHelp.create(locale, color);

    case HelpTopics.ofxMainHelp:
      return OfxMainHelp.create(locale, color);
    case HelpTopics.ofxImportHelp:
      return OfxImportHelp.create(locale, color);
    case HelpTopics.ofxImportFileHelp:
      return OfxImportFileHelp.create(locale, color);
    case HelpTopics.ofxAddTransHelp:
      return OfxAddTransHelp.create(locale, color);
    case HelpTopics.ofxAutoTransHelp:
      return OfxAutoTransHelp.create(locale, color);
    case HelpTopics.ofxDeleteFileHelp:
      return OfxDeleteFileHelp.create(locale, color);

    case HelpTopics.backupRestoreHelp:
      return BackupRestoreHelp.create(locale, color);
    case HelpTopics.backupCreateHelp:
      return BackupCreateHelp.create(locale, color);
    case HelpTopics.backupRestoreOnlyHelp:
      return BackupRestoreOnlyHelp.create(locale, color);

    case HelpTopics.accountsHelp:
      return AccountsHelp.create(locale, color);
    case HelpTopics.accountsEditHelp:
      return AccountsEditHelp.create(locale, color);
    case HelpTopics.accountsDeleteHelp:
      return AccountsDeleteHelp.create(locale, color);

    case HelpTopics.iconsSelectionsHelp:
      return IconsSelectionsHelp.create(locale, color);
    case HelpTopics.iconsColorHelp:
      return IconsColorHelp.create(locale, color);

    case HelpTopics.categoriesHelp:
      return CategoriesHelp.create(locale, color);
    case HelpTopics.categoriesEditHelp:
      return CategoriesEditHelp.create(locale, color);
    case HelpTopics.categoriesBudgetHelp:
      return CategoriesBudgetHelp.create(locale, color);
    case HelpTopics.budgetSetHelp:
      return BudgetSetHelp.create(locale, color);

    case HelpTopics.statisticsHelp:
      return StatisticsHelp.create(locale, color);
    case HelpTopics.statisticsMoveHelp:
      return StatisticsMoveHelp.create(locale, color);
    case HelpTopics.statisticsCardHelp:
      return StatisticsCardHelp.create(locale, color);
    case HelpTopics.statisticsMenuHelp:
      return StatisticsMenuHelp.create(locale, color);

    case HelpTopics.settingsHelp:
      return SettingsHelp.create(locale, color);
    default:
      return SettingsHelp.create(locale, color);
  }
}

Future<void> managerTutorial(
  BuildContext context, [
  HelpTopics topic = HelpTopics.introductionHelp,
]) async {
  StatusButtons buttons = StatusButtons(false, true, true);
  final Color primary = Theme.of(context).colorScheme.primary;
  final locale = AppLocalizations.of(context)!;

  HelpCommand? command = HelpCommand.next;

  int lastPage = HelpTopics.values.length - 1;
  int index = topic.index;

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
      } else if (result is HelpTopics) {
        index = result.index;
        command = HelpCommand.none;
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
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final outlineVariant = colorScheme.outlineVariant;
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
      contentPadding:
          const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),
      children: [
        ...generateText(
          messages: page.messages,
          height: 8,
          color: primary,
        ),
        const SizedBox(height: 6),
        OverflowBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: buttons._previus
                  ? () => Navigator.of(context).pop(HelpCommand.previous)
                  : null,
              icon: Icon(
                Icons.arrow_back_ios,
                color: buttons._previus ? primary : outlineVariant,
              ),
            ),
            FilledButton(
              onPressed: buttons.close
                  ? () => Navigator.of(context).pop(HelpCommand.close)
                  : null,
              child: Text(locale.genericClose),
            ),
            IconButton(
              onPressed: buttons.next
                  ? () => Navigator.of(context).pop(HelpCommand.next)
                  : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: buttons.next ? primary : outlineVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
