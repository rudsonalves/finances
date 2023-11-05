import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../repositories/category/category_repository.dart';

class CategoryDropdownFormField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const CategoryDropdownFormField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final categoryRepository = locator<CategoryRepository>();
    final items = categoryRepository.categoriesMap.keys.toList();

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: DropdownButtonFormField<String>(
        validator: validator,
        value: controller!.text.isNotEmpty ? controller!.text : null,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
          labelText: labelText.toUpperCase(),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    categoryRepository.categoriesMap[item]!.categoryIcon
                        .iconWidget(size: 24),
                    const SizedBox(width: 8),
                    Text(item),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (controller != null) controller!.text = value!;
          if (onChanged != null) onChanged!(value);
        },
      ),
    );
  }
}
