import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:finances/features/import_ofx/widgets/statefull_dialog.dart';
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

  Future<void> importOfxButton() async {
    try {
      final ofxSelect = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select an ofx file',
      );

      if (ofxSelect != null && ofxSelect.files.first.path != null) {
        final ofxFile = File(ofxSelect.files.first.path!);
        final ofx = await _controller.processOfx(ofxFile);

        if (ofx != null) {
          final ofxAccount = OfxAccountModel.fromOfx(ofx);

          if (!mounted) return;
          bool result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return StateFullDialog(ofxAccount: ofxAccount);
                },
              ) ??
              false;
          if (result) {
            log(ofxAccount.toString());
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
        onPressed: importOfxButton,
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
