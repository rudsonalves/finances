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
