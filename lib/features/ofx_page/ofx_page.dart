import 'package:flutter/material.dart';

import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../locator.dart';
import '../../repositories/account/abstract_account_repository.dart';
import 'ofx_page_controller.dart';
import 'ofx_page_state.dart';
import 'widgets/dismissible_ofx_account.dart';

class OfxPage extends StatefulWidget {
  const OfxPage({
    super.key,
  });

  @override
  State<OfxPage> createState() => _OfxPageState();
}

class _OfxPageState extends State<OfxPage> {
  final _controller = locator<OfxPageController>();
  final _accountRepository = locator<AbstractAccountRepository>();

  @override
  initState() {
    super.initState();

    _controller.init();
  }

  // // Add OfxFile
  // Future<void> addOfxFile() async {
  //   try {
  //     final ofxPath = await _pickAndValidateOfxFile();
  //     if (ofxPath == null) return;

  //     final ofx = await _processOfxFile(ofxPath);
  //     if (ofx == null) return;

  //     await _handleOfxImport(ofx, ofxPath);

  //     _controller.ofxFileRegister();
  //   } catch (err) {
  //     await _showUnexpectedErrorMessage();
  //   }
  // }

  // Future<void> _handleOfxImport(Ofx ofx, String ofxPath) async {
  //   // Start a new ofxAccount from loaded ofx
  //   final ofxAccount = OfxAccountModel.fromOfx(ofx);
  //   // ATTEMPTION: this ofx.accountID is the bankAccountId and not user
  //   //             accountId. Ofx is an external package and has its own
  //   //             attribute name.

  //   // Check if exists a ofxRelation to this accountId. Get it if esists.
  //   OfxRelationshipModel? ofxRelation =
  //       await OfxRelationshipManager.getByBankAccountId(ofx.accountID);
  //   // Create a new ofxRelation if not exists
  //   ofxRelation ??= OfxRelationshipModel(bankAccountId: ofx.accountID);

  //   if (ofxRelation.id != null) {
  //     // Set ofxAccount.bankName and accountId from ofxRelation
  //     ofxAccount.bankName = ofxRelation.bankName;
  //     ofxAccount.accountId = ofxRelation.accountId;
  //   }

  //   // Set ofxAccount and ofxRelation
  //   if (!mounted) return;
  //   bool result = await ofxFileImportDialog(
  //     context,
  //     ofxAccount: ofxAccount,
  //     ofxRelation: ofxRelation,
  //     autoTransaction: _controller.autoTransaction,
  //     callback: _controller.setAutoTransaction,
  //   );

  //   if (!result || ofxRelation.accountId == null) return;

  //   bool ok = await _controller.addOfxAccount(
  //     ofxAccount: ofxAccount,
  //     ofxRelation: ofxRelation,
  //   );
  //   if (!ok) {
  //     await _showAlreadyReleasedOfxMessage(ofxPath);
  //     return;
  //   }

  //   // Add transactions
  //   await _ofxCreateTransactions(
  //     ofxAccount: ofxAccount,
  //     ofxRelation: ofxRelation,
  //     ofxTransactions: ofx.transactions,
  //   );
  // }

  // Future<void> _ofxCreateTransactions({
  //   required OfxAccountModel ofxAccount,
  //   required OfxRelationshipModel ofxRelation,
  //   required List<OfxTransaction> ofxTransactions,
  // }) async {
  //   for (final OfxTransaction ofxTransaction in ofxTransactions) {
  //     // Check if exists a ofxTransaction with memo in ofxTrans.memo
  //     OfxTransTemplateModel? ofxTemplate =
  //         await OfxTransTemplateManager.getByMemo(
  //       memo: ofxTransaction.memo,
  //       accountId: ofxRelation.accountId!,
  //     );

  //     // if is necessary, create a new ofxTemplate
  //     ofxTemplate ??= OfxTransTemplateModel.fromOfxTransaction(
  //       ofxTransaction: ofxTransaction,
  //       accountId: ofxAccount.accountId!,
  //     );

  //     // Prepare the new transaction from ofxTemplate
  //     final transaction = TransactionDbModel.fromOfxTempate(
  //       ofxTemplate: ofxTemplate,
  //       transValue: ofxTransaction.amount,
  //       transDate: ExtendedDate.fromDateTime(ofxTransaction.posted),
  //       ofxId: ofxAccount.id!,
  //     );

  //     // Edit Transaction
  //     bool addTransaction = true;
  //     final oldTemplate = OfxTransTemplateModel.copyTemplate(ofxTemplate);
  //     if (!_controller.autoTransaction || transaction.transCategoryId < 1) {
  //       if (!mounted) return;
  //       addTransaction = await showOfxTransactionDialog(
  //         context,
  //         transaction: transaction,
  //         ofxTemplate: ofxTemplate,
  //       );
  //       // await showDialog(
  //       //   context: context,
  //       //   builder: (context) => OfxTransactionPage(
  //       //     transaction: transaction,
  //       //     ofxTemplate: ofxTemplate!,
  //       //   ),
  //       // );
  //     }

  //     // Save template and a new transaction/transfer
  //     if (!addTransaction) {
  //       await _showRemoveTransactionsMessage();
  //       await OfxAccountManager.delete(ofxAccount);
  //       break;
  //     }
  //     // Update/add a new template in ofxTransTemplateTable if
  //     // necessary
  //     if (ofxTemplate.id == null) {
  //       await OfxTransTemplateManager.add(ofxTemplate);
  //     } else if (ofxTemplate != oldTemplate) {
  //       await OfxTransTemplateManager.update(ofxTemplate);
  //     }

  //     // Check if is a transfer between accounts
  //     if (transaction.transCategoryId != TRANSFER_CATEGORY_ID) {
  //       // add a transfer
  //       await TransactionManager.addNew(transaction);
  //     } else {
  //       // add a transaction
  //       await TransferManager.add(
  //           transOrigin: transaction,
  //           accountDestinyId: ofxTemplate.transferAccountId!);
  //     }
  //   }
  // }

  // Future<String?> _pickAndValidateOfxFile() async {
  //   final ofxSelect = await FilePicker.platform.pickFiles(
  //     dialogTitle: 'Select an ofx file',
  //   );
  //   final ofxPath = ofxSelect?.files.first.path!;
  //   if (ofxPath == null) return null;

  //   if (!ofxPath.toLowerCase().endsWith('.ofx')) {
  //     await _showWrongExtensionMessage(ofxPath);
  //     return null;
  //   }

  //   return ofxPath;
  // }

  // Future<Ofx?> _processOfxFile(String ofxPath) async {
  //   final ofxFile = File(ofxPath);
  //   final Ofx? ofx = await _controller.processOfx(ofxFile);
  //   if (ofx == null) {
  //     _showOfxCorruptMessage(ofxPath);
  //     return null;
  //   }
  //   return ofx;
  // }

  // Future<void> _showRemoveTransactionsMessage() async {
  //   if (!mounted) return;
  //   singleMessageAlertDialog(
  //     context,
  //     title: 'Ofx Import Cancel',
  //     message: 'All transactions are being removed!',
  //   );
  // }

  // Future<void> _showAlreadyReleasedOfxMessage(String ofxPath) async {
  //   if (!mounted) return;
  //   await singleMessageAlertDialog(
  //     context,
  //     title: 'Ofx Error',
  //     message: 'This "${ofxPath.split('/').last}" has already been released!',
  //   );
  // }

  // Future<void> _showWrongExtensionMessage(String ofxPath) async {
  //   if (!mounted) return;
  //   await singleMessageAlertDialog(
  //     context,
  //     title: 'Ofx Error',
  //     message: 'This "${ofxPath.split('/').last}" isn\'t an ofx file!',
  //   );
  // }

  // Future<void> _showOfxCorruptMessage(String ofxPath) async {
  //   if (!mounted) return;
  //   await singleMessageAlertDialog(
  //     context,
  //     title: 'Ofx Error',
  //     message: 'This "${ofxPath.split('/').last}" is corrupt!\n'
  //         'I can\'t restore it.',
  //   );
  // }

  // Future<void> _showUnexpectedErrorMessage() async {
  //   if (!mounted) return;
  //   await singleMessageAlertDialog(
  //     context,
  //     title: 'Ofx Error',
  //     message: 'Sorry. An unexpected error has occured.',
  //   );
  // }

  Center noImportedOfxMessage(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_ofx.png',
            scale: 2.5,
          ),
          const SizedBox(height: 20),
          Text(
            'No imported Ofx files!',
            style: AppTextStyles.textStyleSemiBold18.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Imported Ofx'),
        centerTitle: true,
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: addOfxFile,
      //   backgroundColor: colorScheme.primary.withOpacity(0.3),
      //   child: Icon(
      //     Icons.add,
      //     color: colorScheme.onPrimary,
      //   ),
      // ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.onSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        // OfxPage State Loading
                        if (_controller.state is OfxPageStateLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // OfxPage State Success
                        if (_controller.state is OfxPageStateSuccess) {
                          final ofxAccounts = _controller.ofxAccounts;

                          if (ofxAccounts.isEmpty) {
                            noImportedOfxMessage(colorScheme);
                          }

                          return ListView.builder(
                            itemCount: ofxAccounts.length,
                            itemBuilder: (context, index) {
                              final account = _accountRepository
                                  .getAccount(ofxAccounts[index].accountId!);
                              final ofxAccount = ofxAccounts[index];

                              return DismissibleOfxAccount(
                                ofxAccount: ofxAccount,
                                account: account,
                              );
                            },
                          );
                        }
                        // OfxPage State Error
                        return noImportedOfxMessage(colorScheme);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
