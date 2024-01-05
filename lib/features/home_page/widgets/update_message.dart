import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../common/constants/app_info.dart';
import '../../../common/constants/themes/app_button_styles.dart';
import '../../../locator.dart';
import '../../../services/database/database_helper.dart';

Future<void> updateMessage(BuildContext context) async {
  final locale = AppLocalizations.of(context)!;
  final helper = locator<DatabaseHelper>();
  var version = await helper.queryAppVersion();

  if (version != AppInfo.version) {
    bool checkBox = false;
    final String oldVersion = version;

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, StateSetter setState) {
          return AlertDialog(
            title: const Text('News in ${AppInfo.version}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(locale.updateMessage),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: checkBox,
                  controlAffinity: ListTileControlAffinity.leading,
                  // activeColor: AppColors.darkPrimary,
                  subtitle: const Text('Don\'t show this message again'),
                  onChanged: (value) {
                    setState(() {
                      checkBox = value ?? checkBox;
                      version = checkBox ? AppInfo.version : oldVersion;
                    });
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => AppInfo.launchUrl(AppInfo.privacyPolicyUrl),
                style: AppButtonStyles.primaryButtonColor(context),
                child: const Text('Privacy Policy (en)'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: AppButtonStyles.primaryButtonColor(context),
                child: const Text('Close'),
              )
            ],
          );
        },
      ),
    );

    if (version == AppInfo.version) {
      await helper.updateAppVersion(version);
    }
  }
}
