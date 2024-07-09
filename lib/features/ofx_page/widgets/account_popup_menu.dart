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

import '../../../../common/constants/themes/app_text_styles.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/widgets/account_row.dart';
import '../../../locator.dart';
import '../../../repositories/account/abstract_account_repository.dart';

class AccountPopupMenu extends StatefulWidget {
  final int? accountId;
  final void Function(int accountId) callBack;

  const AccountPopupMenu({
    super.key,
    this.accountId,
    required this.callBack,
  });

  @override
  State<AccountPopupMenu> createState() => _AccountPopupMenuState();
}

class _AccountPopupMenuState extends State<AccountPopupMenu> {
  AccountDbModel? account;
  final accountRepository = locator<AbstractAccountRepository>();

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      account = accountRepository.getAccount(widget.accountId!);
    }
  }

  void selectAccount(int accountId) {
    setState(() {
      account = accountRepository.getAccount(accountId);
    });
    widget.callBack(accountId);
  }

  Row accountRow(AccountDbModel? account) {
    return (account != null)
        ? Row(
            children: [
              account.accountIcon.iconWidget(size: 20),
              const SizedBox(width: 6),
              Text(
                account.accountName,
                maxLines: 1,
                style: AppTextStyles.textStyleSemiBold16.copyWith(),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          )
        : Row(
            children: [
              const Icon(Icons.not_interested_outlined),
              const SizedBox(width: 6),
              Text(
                '--none--',
                style: AppTextStyles.textStyleSemiBold16.copyWith(),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final accountList = accountRepository.accountsList;

    return Expanded(
      child: Card(
        elevation: widget.accountId == null ? 1 : 0,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              const Spacer(),
              PopupMenuButton<int>(
                tooltip: locale.cardBalanceMenuTip,
                enabled: widget.accountId == null,
                onSelected: selectAccount,
                itemBuilder: (BuildContext context) {
                  return accountList.map((account) {
                    return PopupMenuItem(
                      value: account.accountId,
                      child: AccountRow(account: account),
                    );
                  }).toList();
                },
                child: accountRow(account),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
