import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../repositories/category/abstract_category_repository.dart';

class CategoryDropdownFormField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final bool removeTransfer;

  const CategoryDropdownFormField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    required this.controller,
    this.readOnly = false,
    this.removeTransfer = false,
  });

  List<String> items() {
    final categoryRepository = locator<AbstractCategoryRepository>();

    final items = <String>[];
    if (removeTransfer) {
      items.addAll(categoryRepository.categoriesMap.keys.where(
          (key) => categoryRepository.categoriesMap[key]!.categoryId != 1));
    } else {
      items.addAll(categoryRepository.categoriesMap.keys);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final categoryRepository = locator<AbstractCategoryRepository>();

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
        items: items()
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
        onChanged: !readOnly
            ? (value) {
                if (controller != null) controller!.text = value!;
                if (onChanged != null) onChanged!(value);
              }
            : null,
      ),
    );
  }
}
