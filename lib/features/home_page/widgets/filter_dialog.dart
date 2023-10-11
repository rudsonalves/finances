import 'package:finances/features/home_page/home_page_controller.dart';
import 'package:finances/repositories/category/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_button_styles.dart';
import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/widgets/autocomplete_text_form_field.dart';
import '../../../locator.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final _homePageController = locator.get<HomePageController>();
  final _categoriesController = locator.get<CategoryRepository>();
  final _controller = TextEditingController();
  final _filterByDescription = ValueNotifier<bool>(true);

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
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Transactions Filter',
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
                          'Descrição',
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
                          'Categoria',
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
                    maxHeight: 160,
                    labelText: 'Filter Text',
                    suggestions: getSugestionsList(),
                    controller: _controller,
                  );
                }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop((
                _controller.text,
                _filterByDescription.value,
              )),
              style: AppButtonStyles.primaryButtonColor(context),
              child: Text(locale.genericClose),
            ),
          ],
        ),
      ),
    );
  }
}
