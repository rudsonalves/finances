import 'package:flutter/material.dart';

import '../models/account_db_model.dart';

class AccountRow extends StatelessWidget {
  final AccountDbModel account;
  final double size;
  const AccountRow({
    super.key,
    required this.account,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        account.accountIcon.iconWidget(size: size),
        const SizedBox(width: 8),
        Text(account.accountName),
      ],
    );
  }
}
