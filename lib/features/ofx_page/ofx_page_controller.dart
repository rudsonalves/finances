import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finances/l10n/app_localizations.dart';
import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';

import '../../common/constants/app_constants.dart';
import '../../common/current_models/current_user.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/ofx_account_model.dart';
import '../../common/models/ofx_relationship_model.dart';
import '../../common/models/ofx_trans_template_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../common/widgets/generic_dialog.dart';
import '../../locator.dart';
import '../../manager/ofx_account_manager.dart';
import '../../manager/ofx_import_manager.dart';
import '../../manager/ofx_relationship_manager.dart';
import '../../manager/ofx_trans_template_manager.dart';
import '../../manager/transaction_manager.dart';
import '../../manager/transfer_manager.dart';
import '../home_page/balance_card/balance_card_controller.dart';
import '../home_page/home_page_controller.dart';
import 'ofx_page_state.dart';
import 'ofx_transactions/ofx_transaction_controller.dart';
import 'ofx_transactions/ofx_transaction_dialog.dart';
import 'widgets/ofx_file_dialog.dart';

class OfxPageController extends ChangeNotifier {
  OfxPageState _state = OfxPageStateInitial();

  final List<OfxAccountModel> _ofxAccounts = [];
  final _homePageController = locator<HomePageController>();
  final _balanceCardController = locator<BalanceCardController>();
  bool _autoTransaction = false;

  void _changeState(OfxPageState newState) {
    _state = newState;
    notifyListeners();
  }

  OfxPageState get state => _state;
  List<OfxAccountModel> get ofxAccounts => _ofxAccounts;
  bool get autoTransaction => _autoTransaction;

  void setAutoTransaction(bool value) => _autoTransaction = value;

  Future<void> init() async {
    loadOfxAccounts();
  }

  Future<void> loadOfxAccounts() async {
    try {
      _changeState(OfxPageStateLoading());

      await OfxAccountManager.getAll(_ofxAccounts);

      _changeState(OfxPageStateSuccess());
    } catch (err) {
      log('OfxPageController.loadOfxAccounts: $err');
      _changeState(OfxPageStateError());
    }
  }

  void ofxFileRegister() {
    loadOfxAccounts();
    _homePageController.setRedraw();
    _balanceCardController.setRedraw();
  }

  Future<bool> addOfxAccount({
    required OfxAccountModel ofxAccount,
    required OfxRelationshipModel ofxRelation,
  }) async {
    try {
      if (ofxRelation.id == null) {
        ofxRelation.bankName = ofxAccount.bankName;
        await OfxRelationshipManager.add(ofxRelation);
      } else if (ofxAccount.bankName != ofxRelation.bankName) {
        await OfxRelationshipManager.update(ofxRelation);
      }

      ofxAccount.accountId = ofxRelation.accountId;
      final ok = await OfxAccountManager.add(ofxAccount);

      return ok;
    } catch (err) {
      log('OfxPageController.addOfxAccount: $err');
      _changeState(OfxPageStateError());
      return false;
    }
  }

  Future<bool> deleteOfxAccount(OfxAccountModel ofxAccount) async {
    try {
      _changeState(OfxPageStateLoading());
      await OfxAccountManager.delete(ofxAccount);
      _homePageController.setRedraw();
      _balanceCardController.setRedraw();
      await loadOfxAccounts();
      _changeState(OfxPageStateSuccess());
      return true;
    } catch (err) {
      log('OfxPageController.deleteOfxAccount: $err');
      _changeState(OfxPageStateError());
      return false;
    }
  }

  Future<Ofx?> processOfx(File ofxFile) async {
    try {
      final ofxBytes = await ofxFile.readAsBytes();
      return Ofx.fromBytes(ofxBytes);
    } catch (err) {
      return null;
    }
  }

  Future<void> showUnexpectedErrorMessage(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;

    await GenericDialog.callDialog(
      context,
      title: locale.ofxDialogUnexpectedErrorTitle,
      message: locale.ofxDialogUnexpectedErrorMsg,
    );
  }

  Future<String?> pickAndValidateOfxFile(BuildContext context) async {
    final ofxSelect = await FilePicker.pickFile(
      dialogTitle: 'Select an ofx file',
    );
    final ofxPath = ofxSelect?.path;
    if (ofxPath == null) return null;

    if (!ofxPath.toLowerCase().endsWith('.ofx')) {
      if (!context.mounted) return null;
      await showWrongExtensionMessage(context, ofxPath);
      return null;
    }

    return ofxPath;
  }

  Future<void> showWrongExtensionMessage(
    BuildContext context,
    String ofxPath,
  ) async {
    final locale = AppLocalizations.of(context)!;
    await GenericDialog.callDialog(
      context,
      title: locale.ofxDialogWrongExtensionTitle,
      message: locale.ofxDialogWrongExtensionMsg(ofxPath.split('/').last),
    );
  }

  Future<Ofx?> processOfxFile(BuildContext context, String ofxPath) async {
    final ofxFile = File(ofxPath);
    final Ofx? ofx = await processOfx(ofxFile);
    if (ofx == null) {
      if (!context.mounted) return null;
      showOfxCorruptMessage(context, ofxPath);
      return null;
    }
    return ofx;
  }

  Future<void> showOfxCorruptMessage(
    BuildContext context,
    String ofxPath,
  ) async {
    final locale = AppLocalizations.of(context)!;
    await GenericDialog.callDialog(
      context,
      title: locale.ofxDialogOfxCorruptTitle,
      message: locale.ofxDialogOfxCorruptMsg(ofxPath.split('/').last),
    );
  }

  Future<void> handleOfxImport(
    BuildContext context, {
    required Ofx ofx,
    required String ofxPath,
  }) async {
    final ofxAccount = OfxAccountModel.fromOfx(ofx);

    OfxRelationshipModel? ofxRelation =
        await OfxRelationshipManager.getByBankAccountId(ofx.accountID);

    ofxRelation ??= OfxRelationshipModel(bankAccountId: ofx.accountID);

    if (ofxRelation.id != null) {
      ofxAccount.bankName = ofxRelation.bankName;
      ofxAccount.accountId = ofxRelation.accountId;
    }

    if (!context.mounted) return;
    bool result = await OfxFileDialog.ofxFileImportDialog(
      context,
      ofxAccount: ofxAccount,
      ofxRelation: ofxRelation,
      autoTransaction: _autoTransaction,
      callback: setAutoTransaction,
    );

    if (!result || ofxRelation.accountId == null) return;

    bool ok = await addOfxAccount(
      ofxAccount: ofxAccount,
      ofxRelation: ofxRelation,
    );
    if (!ok) {
      if (!context.mounted) return;
      await showAlreadyReleasedOfxMessage(context, ofxPath);
      return;
    }

    if (!context.mounted) return;
    await ofxCreateTransactions(
      context,
      ofxAccount: ofxAccount,
      ofxRelation: ofxRelation,
      ofxTransactions: ofx.transactions,
      institutionId: ofx.financialInstitution.financialInstitutionID,
    );
  }

  Future<void> showAlreadyReleasedOfxMessage(
    BuildContext context,
    String ofxPath,
  ) async {
    final locale = AppLocalizations.of(context)!;
    await GenericDialog.callDialog(
      context,
      title: locale.ofxDialogAlreadyReleasedOfxTitle,
      message: locale.ofxDialogAlreadyReleasedOfxMsg(ofxPath.split('/').last),
    );
  }

  Future<void> ofxCreateTransactions(
    BuildContext context, {
    required OfxAccountModel ofxAccount,
    required OfxRelationshipModel ofxRelation,
    required List<OfxTransaction> ofxTransactions,
    required String institutionId,
  }) async {
    for (final ofxTransaction in ofxTransactions) {
      final importKey = (
        institutionId: institutionId,
        bankAccountId: ofxAccount.bankAccountId,
        fitId: ofxTransaction.financialInstitutionID,
      );

      if (await OfxImportManager.isImported(
        institutionId: importKey.institutionId,
        bankAccountId: importKey.bankAccountId,
        fitId: importKey.fitId,
      )) {
        continue;
      }

      OfxTransTemplateModel? ofxTemplate =
          await OfxTransTemplateManager.getByMemo(
        memo: ofxTransaction.memo,
        accountId: ofxRelation.accountId!,
      );

      ofxTemplate ??= OfxTransTemplateModel.fromOfxTransaction(
        ofxTransaction: ofxTransaction,
        accountId: ofxAccount.accountId!,
      );

      final transaction = TransactionDbModel.fromOfxTempate(
        ofxTemplate: ofxTemplate,
        transValue: ofxTransaction.amount,
        transDate: ExtendedDate.fromDateTime(ofxTransaction.posted),
        ofxId: ofxAccount.id!,
      );

      ButtonPress addTransaction = ButtonPress.ok;
      final oldTemplate = OfxTransTemplateModel.copyTemplate(ofxTemplate);
      if (_autoTransaction) {
        final userOfxStopCategories =
            locator<CurrentUser>().userOfxStopCategories;
        if (transaction.transCategoryId < 1 ||
            userOfxStopCategories.contains(transaction.transCategoryId)) {
          if (!context.mounted) return;
          addTransaction = await OfxTransactionDialog.showOfxTransactionDialog(
            context,
            transaction: transaction,
            ofxTemplate: ofxTemplate,
          );
        }
      } else {
        if (!context.mounted) return;
        addTransaction = await OfxTransactionDialog.showOfxTransactionDialog(
          context,
          transaction: transaction,
          ofxTemplate: ofxTemplate,
        );
      }

      if (addTransaction == ButtonPress.skip) {
        continue;
      } else if (addTransaction == ButtonPress.cancel) {
        if (!context.mounted) return;
        await showRemoveTransactionsMessage(context);
        await OfxAccountManager.delete(ofxAccount);
        break;
      }

      final claimed = await OfxImportManager.claim(
        ofxAccountId: ofxAccount.id!,
        institutionId: importKey.institutionId,
        bankAccountId: importKey.bankAccountId,
        fitId: importKey.fitId,
      );
      if (!claimed) {
        continue;
      }

      try {
        if (ofxTemplate.categoryId < 1) {
          log('ATTENTION: ofxTemplate.categoryId < 1');
          ofxTemplate.categoryId = transaction.transCategoryId;
        }
        if (transaction.transDescription != ofxTemplate.description) {
          log(
            'ATTENTION: transaction.transDescription '
            '!= ofxTemplate.description',
          );
          ofxTemplate.description = transaction.transDescription;
        }

        if (ofxTemplate.id == null) {
          await OfxTransTemplateManager.add(ofxTemplate);
        } else if (ofxTemplate != oldTemplate) {
          await OfxTransTemplateManager.update(ofxTemplate);
        }

        if (transaction.transCategoryId != TRANSFER_CATEGORY_ID) {
          await TransactionManager.addNew(transaction);
        } else {
          await TransferManager.add(
            transOrigin: transaction,
            accountDestinyId: ofxTemplate.transferAccountId!,
          );
        }
      } catch (_) {
        await OfxImportManager.release(
          institutionId: importKey.institutionId,
          bankAccountId: importKey.bankAccountId,
          fitId: importKey.fitId,
        );
        rethrow;
      }
    }
  }

  Future<void> showRemoveTransactionsMessage(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    GenericDialog.callDialog(
      context,
      title: locale.ofxDialogRmTransTitle,
      message: locale.ofxDialogRmTransMsg,
    );
  }
}
