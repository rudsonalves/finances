// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../locator.dart';
import '../../repositories/account/abstract_account_repository.dart';
import '../help_manager/main_manager.dart';
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

  Center noImportedOfxMessage(ColorScheme colorScheme) {
    final locale = AppLocalizations.of(context)!;

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
            locale.ofxPageErroMsg,
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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(locale.ofxPageTitle),
        centerTitle: true,
        actions: [
          // Manager Tutorial call
          IconButton(
            icon: const Icon(
              Icons.question_mark,
              size: 20,
            ),
            onPressed: () => managerTutorial(
              context,
              HelpTopics.ofxMainHelp,
            ),
          ),
        ],
      ),
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
                          return Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                            ),
                          );
                        }
                        // OfxPage State Success
                        if (_controller.state is OfxPageStateSuccess) {
                          final ofxAccounts = _controller.ofxAccounts;

                          if (ofxAccounts.isEmpty) {
                            return noImportedOfxMessage(colorScheme);
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
