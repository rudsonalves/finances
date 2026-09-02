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

import 'package:finances/l10n/app_localizations.dart';

class TransactionValidator {
  final AppLocalizations locale;

  TransactionValidator(this.locale);

  String _getOnlyNumbers(String text) => text.replaceAll(RegExp(r'[^\d]'), '');

  double? _numberValue(String text) {
    final String normalized = text.trim();

    if (normalized.contains('-')) return null;

    final String onlyNumbers = _getOnlyNumbers(normalized);
    if (onlyNumbers.isEmpty) return null;

    return int.parse(onlyNumbers) / 100;
  }

  String? amountValidator(String? value) {
    final String amountText = value?.trim() ?? '';

    if (amountText.isEmpty) {
      return locale.transValidatorAmountEmpty;
    }

    final double? amount = _numberValue(amountText);
    if (amount == null || amount <= 0) {
      return locale.transValidatorAmountGt0;
    }

    return null;
  }

  String? descriptionValidator(String? value) {
    final String description = value?.trim() ?? '';

    if (description.isEmpty) return locale.transValidatorDescriptionEmpty;
    if (description.length < 3) return locale.transValidatorDescriptionGt3;

    return null;
  }

  String? categoryValidator(String? value) {
    final String category = value?.trim() ?? '';

    if (category.isEmpty) return locale.transValidatorCategory;

    return null;
  }

  String? dateValidator(String? value) {
    final String dateText = value?.trim() ?? '';

    if (dateText.isEmpty) {
      return locale.transValidatorDateEmpty;
    }

    final RegExp dateRE = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T'
      r'(\d{2}):(\d{2}):(\d{2})\.(\d{6})$',
    );
    final RegExpMatch? match = dateRE.firstMatch(dateText);

    if (match == null) {
      return locale.transValidatorDateValid;
    }

    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    final int hour = int.parse(match.group(4)!);
    final int minute = int.parse(match.group(5)!);
    final int second = int.parse(match.group(6)!);
    final int fraction = int.parse(match.group(7)!);

    final DateTime date = DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      fraction ~/ 1000,
      fraction % 1000,
    );

    final bool isValid = date.year == year &&
        date.month == month &&
        date.day == day &&
        date.hour == hour &&
        date.minute == minute &&
        date.second == second &&
        date.millisecond == fraction ~/ 1000 &&
        date.microsecond == fraction % 1000;

    if (!isValid) {
      return locale.transValidatorDateValid;
    }

    return null;
  }

  String? accountForTransferValidator(int? value) {
    if (value == null || value <= 0) {
      return locale.transPageSelectAccTransfer;
    }

    return null;
  }
}
