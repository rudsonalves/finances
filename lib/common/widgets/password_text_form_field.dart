import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants/themes/colors/custom_colors.dart';

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
            color: CustomColors.unselectedText,
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
