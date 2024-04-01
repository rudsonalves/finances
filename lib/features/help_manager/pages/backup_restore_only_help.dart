import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../model/page_model.dart';

class BackupRestoreOnlyHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  BackupRestoreOnlyHelp(this._title, this._messages);

  static BackupRestoreOnlyHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpBackupRestore8;
    final List<Object> messages = [
      locale.helpBackupRestore6,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_backup_success_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpBackupRestore7,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              locale.helpBackupRestore8,
              style: AppTextStyles.textStyleSemiBold16.copyWith(color: color),
            ),
          ],
        ),
      ],
      locale.helpBackupRestore9,
      locale.helpBackupRestore10,
    ];

    return BackupRestoreOnlyHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
