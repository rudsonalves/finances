import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_text_styles.dart';
import '../../repositories/backup/backup_repository.dart';
import '../../repositories/backup/sqflite_backup_repository.dart';

enum DialogStates {
  create,
  restore,
  createRestore,
}

class DatabaseRecover extends StatefulWidget {
  final DialogStates dialogState;
  const DatabaseRecover({
    super.key,
    required this.dialogState,
  });

  @override
  State<DatabaseRecover> createState() => _DatabaseRecoverState();
}

class _DatabaseRecoverState extends State<DatabaseRecover> {
  final BackupRepository backupRepository = SqfliteBackupRepository();
  String _message = '';

  Future<void> _restoreFunction(AppLocalizations locale) async {
    String selectedFileName = '';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        PlatformFile selectedFile = result.files.first;
        selectedFileName = selectedFile.name;

        backupRepository.restoreBackup(selectedFile.path!);

        setState(() {
          _message = locale.databaseRecoverRetrievedSuccessfully;
        });
      }
    } catch (err) {
      setState(() {
        _message = locale.databaseRecoverSorryRetrieving(selectedFileName);
      });

      log('Error: $err');
    }
  }

  Future<void> _backupFunction(AppLocalizations locale) async {
    try {
      String? destinyPath = await FilePicker.platform.getDirectoryPath();

      if (destinyPath != null) {
        final String? backupPath =
            await backupRepository.createBackup(destinyPath);
        _message = locale.databaseRecoverBasename(path.basename(backupPath!));
      }
    } catch (err) {
      log('Backup Error: $err');
      _message = locale.databaseRecoverSorryError;
    }

    setState(() {});
  }

  List<Widget> dialogMessage() {
    return [
      const SizedBox(height: 16),
      Text(_message),
    ];
  }

  List<Widget> dialogCreateBackup(AppLocalizations locale) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          locale.databaseRecoverCreateBackupData,
        ),
      ),
      OutlinedButton(
        onPressed: () => _backupFunction(locale),
        child: Text(locale.databaseRecoverCreateABackup),
      ),
    ];
  }

  List<Widget> dialogRestoreBackup(AppLocalizations locale) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          locale.databaseRecoverRestoresABackup,
          // textAlign: TextAlign.center,
        ),
      ),
      OutlinedButton(
        onPressed: () => _restoreFunction(locale),
        child: Text(locale.databaseRecoverRestoreABackup),
      ),
    ];
  }

  List<Widget> dialogDivider(AppLocalizations locale) {
    return [
      const SizedBox(height: 8),
      const Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;

    final String title;
    switch (widget.dialogState) {
      case DialogStates.create:
        title = locale.databaseRecoverCreateBackup;
        break;
      case DialogStates.restore:
        title = locale.databaseRecoverRestoreBackup;
        break;
      case DialogStates.createRestore:
        title = locale.databaseRecoverCreateRestoreBackup;
        break;
    }

    return StatefulBuilder(
      builder: (context, setState) => SimpleDialog(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.textStyleSemiBold18.copyWith(
            color: primary,
          ),
        ),
        children: [
          if ([DialogStates.create, DialogStates.createRestore]
              .contains(widget.dialogState))
            ...dialogCreateBackup(locale),
          if (widget.dialogState == DialogStates.createRestore)
            ...dialogDivider(locale),
          if ([DialogStates.restore, DialogStates.createRestore]
              .contains(widget.dialogState))
            ...dialogRestoreBackup(locale),
          if (_message.isNotEmpty) ...dialogMessage(),
          Row(
            children: [
              const Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(primary),
                    foregroundColor: MaterialStatePropertyAll(onPrimary),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(locale.genericClose),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
