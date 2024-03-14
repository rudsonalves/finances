import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finances/common/models/ofx_relationship_model.dart';
import 'package:finances/features/import_ofx/widgets/ofx_file_dialog.dart';
import 'package:finances/manager/ofx_account_manager.dart';
import 'package:finances/manager/ofx_relationship_manager.dart';
import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';

import '../../common/models/ofx_account_model.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import 'ofx_page_controller.dart';
import 'ofx_page_state.dart';

class OfxPage extends StatefulWidget {
  const OfxPage({super.key});

  @override
  State<OfxPage> createState() => _OfxPageState();
}

class _OfxPageState extends State<OfxPage> {
  final _controller = OfxPageController();

  Future<void> addOfxFile() async {
    try {
      // Pick ofx file
      final ofxSelect = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select an ofx file',
      );

      if (ofxSelect != null && ofxSelect.files.first.path != null) {
        final String ofxPath = ofxSelect.files.first.path!;
        if (!ofxPath.toLowerCase().endsWith('.ofx')) {
          log('This is not a ofx file!');
          // FIXME: Show a message!!!
          return;
        }
        final ofxFile = File(ofxPath);
        final ofx = await _controller.processOfx(ofxFile);

        if (ofx != null) {
          final ofxAccount = OfxAccountModel.fromOfx(ofx);

          // ATTEMPTION: this ofx.accountID is the bankAccountId and not user
          //             accountId. Ofx is an external package and has its own
          //             attribute name.
          OfxRelationshipModel? ofxRelation =
              await OfxRelationshipManager.getByBankAccountId(ofx.accountID);
          ofxRelation ??= OfxRelationshipModel(bankAccountId: ofx.accountID);

          if (ofxRelation.id != null) {
            ofxAccount.bankName = ofxRelation.bankName;
          }

          if (!mounted) return;
          bool result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return OfxFileDialog(
                    ofxAccount: ofxAccount,
                    ofxRelation: ofxRelation!,
                  );
                },
              ) ??
              false;
          if (result && ofxRelation.accountId != null) {
            if (ofxRelation.id == null) {
              // Save a new ofx file relationship between accountID
              // bankAccountId and accountId
              ofxRelation.bankName = ofxAccount.bankName;
              await OfxRelationshipManager.add(ofxRelation);
            }
            if (ofxAccount.bankName != ofxRelation.bankName) {
              // update ofxRelationship
              await OfxRelationshipManager.update(ofxRelation);
            }
            // Register ofx file
            ofxAccount.accountId = ofxRelation.accountId;
            final result = await OfxAccountManager.add(ofxAccount);

            if (result) {
              log('Add ofxAccount!');
            } else {
              log('Recussed ofxAccount!');
            }
          }
        } else {
          log('Error!!!');
        }
      }
    } catch (err) {
      log('FilePicker: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Imported Ofx'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addOfxFile,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      if (_controller.state is OfxPageStateLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (_controller.state is OfxPageStateSuccess) {
                        Ofx ofx = _controller.ofx!;

                        return Column(
                          children: [
                            Text('AccoutId: ${ofx.accountID}'),
                            Text('Bank: ${ofx.bankID}'),
                            Text('Type: ${ofx.accountType}'),
                            Text('Currency: ${ofx.currency}'),
                            Text(
                                'Institution: ${ofx.financialInstitution.organization}'),
                            Text(
                                'InstitutionId: ${ofx.financialInstitution.financialInstitutionID}'),
                            Text('Transactions: ${ofx.transactions.length}'),
                            Text('Start: ${ofx.start}'),
                            Text('End: ${ofx.end}'),
                            Text('server: ${ofx.server}'),
                          ],
                        );
                      }

                      return const Center(
                        child: Text('No imported Ofx files'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
