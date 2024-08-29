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

import '../constants/themes/colors/app_colors.dart';

class PasswordTextFormField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final String? hintText;
  final String? Function(String?)? validator;

  const PasswordTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.hintText,
    this.validator,
  });

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: TextFormField(
        controller: widget.controller,
        obscureText: isHidden,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            color: AppColors.unselectedText,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          labelText: widget.labelText.toUpperCase(),
          hintText: widget.hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Focus(
            descendantsAreFocusable: false,
            canRequestFocus: false,
            child: IconButton(
              tooltip: locale.passwordWidgetShowPassword,
              icon: Icon(isHidden ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  isHidden = !isHidden;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
