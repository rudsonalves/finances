import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../locator.dart';
import '../../repositories/account/abstract_account_repository.dart';

class AccountDropdownFormField extends StatefulWidget {
  final GlobalKey<FormFieldState<int>> globalKey;
  final int originAccountId;
  final int? destinationAccountId;
  final String? Function(int?)? validate;
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(int) accountIdSelected;
  final Widget? suffixIcon;

  const AccountDropdownFormField({
    super.key,
    required this.globalKey,
    required this.originAccountId,
    required this.validate,
    this.destinationAccountId,
    required this.hintText,
    required this.labelText,
    this.validator,
    required this.accountIdSelected,
    this.suffixIcon,
  });

  @override
  State<AccountDropdownFormField> createState() =>
      _AccountDropdownFormFieldState();
}

class _AccountDropdownFormFieldState extends State<AccountDropdownFormField> {
  final TextEditingController _controller = TextEditingController();
  final accountsMap = locator<AbstractAccountRepository>().accountsMap;
  int? _selectedAccountIndex;

  @override
  void initState() {
    _selectedAccountIndex = widget.destinationAccountId;
    _controller.text = _selectedAccountIndex != null
        ? accountsMap[_selectedAccountIndex!]!.accountName
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
    log('inputs: $_selectedAccountIndex ${widget.originAccountId}');
    accountIds.remove(widget.originAccountId);
    if (widget.originAccountId == _selectedAccountIndex) {
      _selectedAccountIndex = null;
    }
    _controller.text = _selectedAccountIndex != null
        ? accountsMap[_selectedAccountIndex!]!.accountName
        : '';

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: DropdownButtonFormField<int>(
        key: widget.globalKey,
        value: _selectedAccountIndex,
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
            _selectedAccountIndex = index;
            _controller.text = accountsMap[index]!.accountName;
            widget.accountIdSelected(index);
          }
        },
      ),
    );
  }
}
