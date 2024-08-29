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

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/widgets/autocomplete_text_form_field.dart';
import '../../../locator.dart';
import '../../../repositories/category/abstract_category_repository.dart';
import '../home_page_controller.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final _homePageController = locator<HomePageController>();
  final _categoriesController = locator<AbstractCategoryRepository>();
  final _controller = TextEditingController();
  final _filterByDescription = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _categoriesController.init();
  }

  List<String> getSugestionsList() {
    List<String> suggestions = [];
    if (_filterByDescription.value) {
      suggestions = _homePageController.cacheDescriptions.keys.toList();
    } else {
      suggestions = _categoriesController.categoriesMap.keys.toList();
    }

    return suggestions;
  }

  @override
  void dispose() {
    _controller.dispose();
    _filterByDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final locale = AppLocalizations.of(context)!;
    double maxHeight = MediaQuery.of(context).size.height;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.filterDialogTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.textStyleSemiBold20.copyWith(
                color: primary,
              ),
            ),
            Row(
              children: [
                Ink(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: InkWell(
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                            valueListenable: _filterByDescription,
                            builder: (context, _, __) {
                              return Icon(
                                _filterByDescription.value
                                    ? Icons.task_alt
                                    : Icons.radio_button_unchecked,
                                color: primary,
                              );
                            }),
                        const SizedBox(width: 12),
                        Text(
                          locale.filterDialogDescription,
                          style: AppTextStyles.textStyleSemiBold16.copyWith(
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _filterByDescription.value = true;
                      _controller.text = '';
                    },
                  ),
                ),
                const Spacer(),
                Ink(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: InkWell(
                    child: Row(
                      children: [
                        ValueListenableBuilder(
                            valueListenable: _filterByDescription,
                            builder: (context, _, __) {
                              return Icon(
                                !_filterByDescription.value
                                    ? Icons.task_alt
                                    : Icons.radio_button_unchecked,
                                color: primary,
                              );
                            }),
                        const SizedBox(width: 12),
                        Text(
                          locale.filterDialogCategory,
                          style: AppTextStyles.textStyleSemiBold16.copyWith(
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _filterByDescription.value = false;
                      _controller.text = '';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
                valueListenable: _filterByDescription,
                builder: (context, _, __) {
                  return AutocompleteTextFormField(
                    maxHeight: 160 * maxHeight / 813.1,
                    labelText: locale.filterDialogLabel,
                    suggestions: getSugestionsList(),
                    controller: _controller,
                  );
                }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).pop((
                _controller.text,
                _filterByDescription.value,
              )),
              child: Text(locale.filterDialogButton),
            ),
          ],
        ),
      ),
    );
  }
}
