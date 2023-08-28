import 'package:flutter/material.dart';

import '../../common/current_models/current_account.dart';
import '../../locator.dart';
import '../../repositories/account/account_repository.dart';

class AccountDropdownFormField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(int?)? onChanged;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const AccountDropdownFormField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentAccount = locator.get<CurrentAccount>();
    final accountRepository = locator.get<AccountRepository>();
    final items = accountRepository.accountsMap.keys.toList();
    items.remove(currentAccount.accountId);

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: DropdownButtonFormField<int>(
        value: controller!.text.isNotEmpty
            ? accountRepository.accountIdByName(controller!.text)
            : null,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: items.isEmpty
              ? 'Create a new account to make transfers'
              : hintText,
          labelText: labelText.toUpperCase(),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
        items: items
            .map(
              (index) => DropdownMenuItem(
                value: index,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    accountRepository.accountsMap[index]!.accountIcon
                        .iconWidget(size: 24),
                    const SizedBox(width: 8),
                    Text(accountRepository.accountsMap[index]!.accountName),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (index) {
          if (index != null) {
            if (controller != null) {
              controller!.text =
                  accountRepository.accountsMap[index]!.accountName;
            }
            if (onChanged != null) onChanged!(index);
          }
        },
      ),
    );
  }
}
