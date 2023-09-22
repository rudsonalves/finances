import 'package:flutter/material.dart';

class BasicTextFormField extends StatelessWidget {
  final String labelText;
  final String? prefixText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? hintText;
  final TextCapitalization capitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onchanged;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? initialValue;

  const BasicTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.name,
    this.textInputAction = TextInputAction.next,
    this.hintText,
    this.capitalization = TextCapitalization.none,
    this.validator,
    this.prefixText,
    this.onchanged,
    this.suffixIcon,
    this.focusNode,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Semantics(
        label: labelText,
        child: TextFormField(
          initialValue: initialValue,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: capitalization,
          validator: validator,
          onChanged: onchanged,
          focusNode: focusNode,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.outlineVariant,
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
      ),
    );
  }
}
