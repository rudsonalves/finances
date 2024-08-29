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

import '../../../../common/constants/app_info.dart';
import '../../../common/widgets/markdown_rich_text.dart';
import '../../../locator.dart';
import '../../../repositories/database/abstract_database_repository.dart';

Future<void> updateMessage(BuildContext context) async {
  final locale = AppLocalizations.of(context)!;
  final helper = locator<AbstractDatabaseRepository>();
  final primary = Theme.of(context).colorScheme.primary;
  var version = await helper.queryAppVersion();

  if (version != AppInfo.version) {
    bool checkBox = false;
    final String oldVersion = version;

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, StateSetter setState) {
          return AlertDialog(
            title: Text(
                '${locale.aboutPageVersion} ${AppInfo.version.split('+')[0]}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarkdownRichText.richText(
                    locale.updateMessage,
                    color: primary,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: checkBox,
                        onChanged: (value) {
                          setState(() {
                            checkBox = value ?? checkBox;
                            version = checkBox ? AppInfo.version : oldVersion;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          locale.aboutPageCheckBox,
                          style: TextStyle(color: primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => AppInfo.launchUrl(AppInfo.privacyPolicyUrl),
                child: Text(locale.updatePoliceButton),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(locale.genericClose),
              )
            ],
          );
        },
      ),
    );

    if (checkBox) {
      await helper.updateAppVersion(version);
    }
  }
}
