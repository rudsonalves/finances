import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/app_constants.dart';
import '../../common/current_models/current_user.dart';
import '../../common/models/extends_date.dart';
import '../../common/models/ofx_account_model.dart';
import '../../common/models/ofx_relationship_model.dart';
import '../../common/models/ofx_trans_template_model.dart';
import '../../common/models/transaction_db_model.dart';
import '../../common/widgets/widget_alert_dialog.dart';
import '../../locator.dart';
import '../../manager/ofx_account_manager.dart';
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
        // Save a new ofx file relationship between accountID
        // bankAccountId and accountId
        ofxRelation.bankName = ofxAccount.bankName;
        await OfxRelationshipManager.add(ofxRelation);
      } else if (ofxAccount.bankName != ofxRelation.bankName) {
        // update ofxRelationship
        await OfxRelationshipManager.update(ofxRelation);
      }
      // Register ofxAccount file
      ofxAccount.accountId = ofxRelation.accountId;
      final ok = await OfxAccountManager.add(ofxAccount);

      // await OfxAccountManager.getAll(_ofxAccounts);

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
      final ofxString = await ofxFile.readAsString();
      final ofx = _parserOfxSXml(ofxString);
      return ofx;
    } catch (err) {
      return null;
    }
  }

  Ofx _parserOfxSXml(String xml) {
    // First try to parser xml
    Ofx? ofx = _attemptParseXml(xml);

    // if the parser fails, try fixing xml and parser again
    if (ofx == null) {
      String fixedXml = _fixingXml(xml);
      ofx = _attemptParseXml(fixedXml);
    }

    if (ofx == null) {
      throw Exception('parseOfxString: Ofx XML can not be fixed.');
    }

    return ofx;
  }

  Ofx? _attemptParseXml(String xml) {
    try {
      final ofx = Ofx.fromString(xml);
      return ofx;
    } catch (err) {
      // log('XML parsing error: $err');
      return null;
    }
  }

  String _fixingXml(String xml) {
    String newXml = '';
    final lines = xml.split('\n');

    final completTag = RegExp(r'^<([a-zA-Z\d]+)>([^<>]+)</([a-zA-Z\d]+)>$');
    final halfTag = RegExp(r'^<([a-zA-Z\d]+)>([^<>]+)$');

    for (final line in lines) {
      final trimLine = line.trim();
      // remove empty lines
      if (trimLine.isEmpty) continue;
      // check complet tags match
      final completMatch = completTag.firstMatch(trimLine);
      if (completMatch != null) {
        if (completMatch.group(1) != completMatch.group(3)) {
          newXml +=
              '<${completMatch.group(1)}>${completMatch.group(2)}</${completMatch.group(1)}>\n';
          newXml += '</${completMatch.group(3)}>\n';
        } else {
          newXml += '$line\n';
        }
        continue;
      }
      // check half tags match
      final halfMatch = halfTag.firstMatch(line);
      if (halfMatch != null) {
        newXml += '$line</${halfMatch.group(1)}>\n';
      } else {
        newXml += '$line\n';
      }
    }

    return newXml;
  }

  Future<void> showUnexpectedErrorMessage(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;

    await singleMessageAlertDialog(
      context,
      title: locale.ofxDialogUnexpectedErrorTitle,
      message: locale.ofxDialogUnexpectedErrorMsg,
    );
  }

  Future<String?> pickAndValidateOfxFile(BuildContext context) async {
    final ofxSelect = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select an ofx file',
    );
    final ofxPath = ofxSelect?.files.first.path!;
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
    await singleMessageAlertDialog(
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
    await singleMessageAlertDialog(
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
    // Start a new ofxAccount from loaded ofx
    final ofxAccount = OfxAccountModel.fromOfx(ofx);
    // ATTEMPTION: this ofx.accountID is the bankAccountId and not user
    //             accountId. Ofx is an external package and has its own
    //             attribute name.

    // Check if exists a ofxRelation to this accountId. Get it if esists.
    OfxRelationshipModel? ofxRelation =
        await OfxRelationshipManager.getByBankAccountId(ofx.accountID);
    // Create a new ofxRelation if not exists
    ofxRelation ??= OfxRelationshipModel(bankAccountId: ofx.accountID);

    if (ofxRelation.id != null) {
      // Set ofxAccount.bankName and accountId from ofxRelation
      ofxAccount.bankName = ofxRelation.bankName;
      ofxAccount.accountId = ofxRelation.accountId;
    }

    // Set ofxAccount and ofxRelation
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

    // Add transactions
    if (!context.mounted) return;
    await ofxCreateTransactions(
      context,
      ofxAccount: ofxAccount,
      ofxRelation: ofxRelation,
      ofxTransactions: ofx.transactions,
    );
  }

  Future<void> showAlreadyReleasedOfxMessage(
    BuildContext context,
    String ofxPath,
  ) async {
    final locale = AppLocalizations.of(context)!;
    await singleMessageAlertDialog(
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
  }) async {
    for (final ofxTransaction in ofxTransactions) {
      // Check if exists a ofxTransaction with memo in ofxTrans.memo
      OfxTransTemplateModel? ofxTemplate =
          await OfxTransTemplateManager.getByMemo(
        memo: ofxTransaction.memo,
        accountId: ofxRelation.accountId!,
      );

      // if is necessary, create a new ofxTemplate
      ofxTemplate ??= OfxTransTemplateModel.fromOfxTransaction(
        ofxTransaction: ofxTransaction,
        accountId: ofxAccount.accountId!,
      );

      // Prepare the new transaction from ofxTemplate
      final transaction = TransactionDbModel.fromOfxTempate(
        ofxTemplate: ofxTemplate,
        transValue: ofxTransaction.amount,
        transDate: ExtendedDate.fromDateTime(ofxTransaction.posted),
        ofxId: ofxAccount.id!,
      );

      // Edit Transaction
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
        // Remove transactions and OfxAccount
        if (!context.mounted) return;
        await showRemoveTransactionsMessage(context);
        await OfxAccountManager.delete(ofxAccount);
        break;
      }

      // FIXME: Remove this lines!
      // Update ofxTemplate categoryId and description
      if (ofxTemplate.categoryId < 1) {
        log('ATTENTION: ofxTemplate.categoryId < 1');
        ofxTemplate.categoryId = transaction.transCategoryId;
      }
      if (transaction.transDescription != ofxTemplate.description) {
        log('ATTENTION: transaction.transDescription != ofxTemplate.description');
        ofxTemplate.description = transaction.transDescription;
      }

      // Update/add a new template in ofxTransTemplateTable if
      // necessary
      if (ofxTemplate.id == null) {
        await OfxTransTemplateManager.add(ofxTemplate);
      } else if (ofxTemplate != oldTemplate) {
        await OfxTransTemplateManager.update(ofxTemplate);
      }

      // Check if is a transfer between accounts
      if (transaction.transCategoryId != TRANSFER_CATEGORY_ID) {
        // add a transfer
        await TransactionManager.addNew(transaction);
      } else {
        // add a transaction
        await TransferManager.add(
            transOrigin: transaction,
            accountDestinyId: ofxTemplate.transferAccountId!);
      }
    }
  }

  Future<void> showRemoveTransactionsMessage(BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    singleMessageAlertDialog(
      context,
      title: locale.ofxDialogRmTransTitle,
      message: locale.ofxDialogRmTransMsg,
    );
  }
}
