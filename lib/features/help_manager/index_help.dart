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

import 'main_manager.dart';

class IndexHelp extends StatelessWidget {
  const IndexHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    final helpIndex = <String, HelpTopics>{
      locale.helpIntroductionTitle: HelpTopics.introductionHelp,
      locale.helpPresentationTitle: HelpTopics.presentationHelp,
      locale.helpTransactionsTitle: HelpTopics.transactionsHelp,
      locale.helpOfxTitle: HelpTopics.ofxMainHelp,
      locale.helpBackupRestoreTitle: HelpTopics.backupRestoreHelp,
      locale.helpAccountsTitle: HelpTopics.accountsHelp,
      locale.helpIconsSelectionsTitle: HelpTopics.iconsSelectionsHelp,
      locale.helpCategoriesTitle: HelpTopics.categoriesHelp,
      locale.helpBudgetSetTitle: HelpTopics.budgetSetHelp,
      locale.helpStatisticsTitle: HelpTopics.statisticsHelp,
      locale.helpSettingsTitle: HelpTopics.settingsHelp,
    };

    final List<Widget> widgets = [];

    int index = 1;
    for (final helpTitle in helpIndex.keys) {
      widgets.add(
        InkWell(
          onTap: () {
            navigator.pop(helpIndex[helpTitle]);
          },
          child: Text(
            '${index.toString().padLeft(2, '0')}. $helpTitle',
            style: TextStyle(
              color: primary,
            ),
          ),
        ),
      );
      index++;
    }

    return SimpleDialog(
      title: Text(
        locale.helpIndexTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primary,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      children: [
        ...widgets,
        const SizedBox(height: 6),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(HelpCommand.close),
              child: Text(locale.genericClose),
            ),
          ],
        ),
      ],
    );
  }
}
