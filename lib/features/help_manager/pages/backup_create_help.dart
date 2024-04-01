import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/page_model.dart';

class BackupCreateHelp implements PageModel {
  final String _title;
  final List<Object> _messages;

  BackupCreateHelp(this._title, this._messages);

  static BackupCreateHelp create(AppLocalizations locale, Color color) {
    String title = locale.helpBackupRestore2;
    final List<Object> messages = [
      locale.helpBackupRestore3,
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Image.asset(
                'assets/images/transaction_backup_help.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
      locale.helpBackupRestore4,
      locale.helpBackupRestore5,
    ];

    return BackupCreateHelp(title, messages);
  }

  @override
  List<Object> get messages => _messages;

  @override
  String get title => _title;
}
