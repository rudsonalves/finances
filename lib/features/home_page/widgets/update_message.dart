import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../common/constants/app_info.dart';
import '../../../common/constants/themes/app_button_styles.dart';
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
              ElevatedButton(
                onPressed: () => AppInfo.launchUrl(AppInfo.privacyPolicyUrl),
                style: AppButtonStyles.primaryButtonColor(context),
                child: Text(locale.updatePoliceButton),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppButtonStyles.primaryButtonColor(context),
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
