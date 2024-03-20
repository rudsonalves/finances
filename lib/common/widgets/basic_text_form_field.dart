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
