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

import '../../../../locator.dart';
import '../../../../repositories/account/abstract_account_repository.dart';

class DestinyAccountDropdownForm extends StatefulWidget {
  final GlobalKey<FormFieldState<int>> globalKey;
  final int originAccountId;
  final int? destinyAccountId;
  final String? Function(int?)? validate;
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(int) accountIdSelected;
  final Widget? suffixIcon;

  const DestinyAccountDropdownForm({
    super.key,
    required this.globalKey,
    required this.originAccountId,
    required this.validate,
    this.destinyAccountId,
    required this.hintText,
    required this.labelText,
    this.validator,
    required this.accountIdSelected,
    this.suffixIcon,
  });

  @override
  State<DestinyAccountDropdownForm> createState() =>
      _DestinyAccountDropdownFormState();
}

class _DestinyAccountDropdownFormState
    extends State<DestinyAccountDropdownForm> {
  final TextEditingController _controller = TextEditingController();
  final accountsMap = locator<AbstractAccountRepository>().accountsMap;
  int? _selectedAccountId;

  @override
  void initState() {
    _selectedAccountId = widget.destinyAccountId;
    _controller.text = _selectedAccountId != null
        ? accountsMap[_selectedAccountId!]!.accountName
        : '';
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountIds = accountsMap.keys.toList();
    final locale = AppLocalizations.of(context)!;
    accountIds.remove(widget.originAccountId);
    if (widget.originAccountId == _selectedAccountId) {
      _selectedAccountId = null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: DropdownButtonFormField<int>(
        key: widget.globalKey,
        value: _selectedAccountId,
        validator: widget.validate,
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: accountIds.isEmpty
              ? locale.accountDropdownFormHint
              : widget.hintText,
          labelText: widget.labelText.toUpperCase(),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
        items: accountIds
            .map(
              (index) => DropdownMenuItem(
                value: index,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    accountsMap[index]!.accountIcon.iconWidget(size: 24),
                    const SizedBox(width: 8),
                    Text(accountsMap[index]!.accountName),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (index) {
          if (index != null) {
            _selectedAccountId = index;
            _controller.text = accountsMap[index]!.accountName;
            widget.accountIdSelected(index);
          }
        },
      ),
    );
  }
}
