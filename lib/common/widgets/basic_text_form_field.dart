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

import '../constants/themes/colors/app_colors.dart';

class BasicTextFormField extends StatelessWidget {
  final String labelText;
  final String? prefixText;
  final TextStyle? style;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? hintText;
  final TextCapitalization capitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onchanged;
  final void Function()? onEditingComplete;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool readOnly;

  const BasicTextFormField({
    super.key,
    required this.labelText,
    this.controller,
    this.style,
    this.keyboardType = TextInputType.name,
    this.textInputAction = TextInputAction.next,
    this.hintText,
    this.capitalization = TextCapitalization.none,
    this.validator,
    this.prefixText,
    this.onchanged,
    this.onEditingComplete,
    this.suffixIcon,
    this.focusNode,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: TextFormField(
        style: style,
        readOnly: readOnly,
        initialValue: initialValue,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: capitalization,
        validator: validator,
        onChanged: onchanged,
        onEditingComplete: onEditingComplete,
        focusNode: focusNode,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixText: prefixText,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.unselectedText,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          labelText: labelText.toUpperCase(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}
