import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryTextFormField extends StatelessWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;

  const CategoryTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        initialValue: initialValue,
        controller: controller,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          labelText: locale.categoryTextFieldNAME,
          hintText: locale.categoryTextFieldEnterDiffCatName,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
