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

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountValidator {
  final AppLocalizations locale;

  AccountValidator(this.locale);

  String? nameValidator(String? value) {
    final String name = value ?? '';

    if (name.isEmpty) return locale.statefullAccountDialogNameEmpty;
    if (name.length < 2) return locale.statefullAccountDialogNameGt3;

    return null;
  }

  String? descriptionValidator(String? value) {
    final String description = value ?? '';

    if (description.isEmpty) return locale.statefullAccountDialogDescripEmpty;
    if (description.length < 3) return locale.statefullAccountDialogDescripGt3;

    return null;
  }
}
