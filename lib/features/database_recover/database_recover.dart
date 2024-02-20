import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:restart_app/restart_app.dart';

import '../../common/constants/routes/app_route.dart';
import '../../common/constants/themes/app_button_styles.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../repositories/backup/abstract_backup_repository.dart';
import '../../repositories/backup/backup_repository.dart';

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
  final AbstractBackupRepository _backupRepository = BackupRepository();
  String _message = '';

  Future<void> _restoreFunction(AppLocalizations locale) async {
    String selectedFileName = '';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        PlatformFile selectedFile = result.files.first;
        selectedFileName = selectedFile.name;

        await _backupRepository.restoreBackup(selectedFile.path!);

        setState(() {
          _message = locale.databaseRecoverRetrievedSuccessfully;
        });

        await Restart.restartApp(webOrigin: AppRoute.onboard.name);
      }
    } catch (err) {
      setState(() {
        _message = locale.databaseRecoverSorryRetrieving(selectedFileName);
      });

      Logger().e('Error: $err');
    }
  }

  Future<void> _backupFunction(AppLocalizations locale) async {
    try {
      String? destinyPath = await FilePicker.platform.getDirectoryPath();

      if (destinyPath != null) {
        final String? backupPath =
            await _backupRepository.createBackup(destinyPath);
        _message = locale.databaseRecoverBasename(path.basename(backupPath!));
      }
    } catch (err) {
      log('Backup Error: $err');
      _message = locale.databaseRecoverSorryError;
    }

    setState(() {});
  }

  Widget dialogMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(_message),
    );
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

  Widget dialogDivider(AppLocalizations locale) {
    return const Divider(
      height: 16,
    );
  }

  List<Widget> _buildDialogContent(AppLocalizations locale) {
    final contentWidgets = <Widget>[];

    if (_message.isNotEmpty) {
      contentWidgets.add(dialogMessage());
    } else {
      if ([DialogStates.create, DialogStates.createRestore]
          .contains(widget.dialogState)) {
        contentWidgets.addAll(dialogCreateBackup(locale));
      }

      if (widget.dialogState == DialogStates.createRestore) {
        contentWidgets.add(dialogDivider(locale));
      }

      if ([DialogStates.restore, DialogStates.createRestore]
          .contains(widget.dialogState)) {
        contentWidgets.addAll(dialogRestoreBackup(locale));
      }
    }

    return contentWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;
    final primary = colorScheme.primary;
    final buttonStyle = AppButtonStyles.primaryButtonColor(context);

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
          ..._buildDialogContent(locale),
          Row(
            children: [
              const Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: buttonStyle,
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
