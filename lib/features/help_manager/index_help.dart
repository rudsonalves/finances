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

    final titles = <String>[
      locale.helpIntroductionTitle,
      locale.helpPresentationTitle,
      locale.helpTransactionsTitle,
      locale.helpTransactionsCardTitle,
      locale.helpTransactionsEditTitle,
      locale.helpTransactionsAddTitle,
      locale.helpTransactionsLockTitle,
      locale.helpTransactionsFutureTitle,
      locale.helpTransactionsFilterTitle,
      locale.helpBackupRestoreTitle,
      locale.helpAccountsTitle,
      locale.helpAccountsEditTitle,
      locale.helpAccountsDeleteTitle,
      locale.helpIconsSelectionsTitle,
      locale.helpIconsColorTitle,
      locale.helpCategoriesTitle,
      locale.helpCategoriesEditTitle,
      locale.helpCategoriesBudgetTitle,
      locale.helpBudgetSetTitle,
      locale.helpStatisticsTitle,
      locale.helpStatisticsMoveTitle,
      locale.helpStatisticsCardTitle,
      locale.helpStatisticsMenuTitle,
      locale.helpSettingsTitle,
    ];

    final List<Widget> widgets = [];

    for (int index = 0; index < titles.length; index++) {
      widgets.add(
        InkWell(
          onTap: () {
            navigator.pop(index);
          },
          child: Text(
            '${(index + 1).toString().padLeft(2, '0')}. ${titles[index]}',
            style: TextStyle(
              color: primary,
            ),
          ),
        ),
      );
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
