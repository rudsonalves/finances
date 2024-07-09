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
import '../../../common/constants/themes/colors/custom_color.g.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/ofx_trans_template_model.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../common/widgets/account_row.dart';
import '../../../common/widgets/autocomplete_text_form_field.dart';
import '../../../common/widgets/basic_text_form_field.dart';
import '../../../common/widgets/category_dropdown_form_field.dart';
import '../../../common/widgets/date_time_picker_form.dart';
import '../../../locator.dart';
import '../../categories/categories_controller.dart';
import '../../categories/widget/add_category_page.dart';
import '../../home_page/home_page_controller.dart';
import '../../transaction/widget/destiny_account_dropdown_form.dart';
import 'ofx_transaction_controller.dart';

class OfxTransactionDialog extends StatefulWidget {
  final TransactionDbModel transaction;
  final OfxTransTemplateModel ofxTemplate;

  static const routeName = '/ofx_page/ofx_transaction';

  const OfxTransactionDialog({
    super.key,
    required this.transaction,
    required this.ofxTemplate,
  });

  static Future<ButtonPress> showOfxTransactionDialog(
    BuildContext context, {
    required TransactionDbModel transaction,
    required OfxTransTemplateModel ofxTemplate,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => OfxTransactionDialog(
        transaction: transaction,
        ofxTemplate: ofxTemplate,
      ),
    );
  }

  @override
  State<OfxTransactionDialog> createState() => _OfxTransactionDialogState();
}

class _OfxTransactionDialogState extends State<OfxTransactionDialog> {
  final _controller = OfxTransactionController();
  final _homePageController = locator<HomePageController>();
  final _destinyKey = GlobalKey<FormFieldState<int>>();

  @override
  void initState() {
    super.initState();
    _controller.init(
      accountId: widget.transaction.transAccountId,
      transaction: widget.transaction,
      ofxTransTemplate: widget.ofxTemplate,
    );
    _controller.amount.text = widget.transaction.transValue.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addCategoryAction() async {
    final CategoryDbModel? newCategory = await showDialog(
      context: context,
      builder: (context) => AddCategoryPage(
        callBack: locator<CategoriesController>().getAllCategories,
      ),
    );

    if (newCategory != null) {
      _controller.setCategoryByName(newCategory.categoryName);
    }

    setState(() {});
  }

  void _navigatorPopOk() {
    widget.transaction.transDescription =
        _controller.descriptionController.text;
    widget.ofxTemplate.description = _controller.descriptionController.text;
    Navigator.pop(context, ButtonPress.ok);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final account = _controller.getAccountById(
      widget.transaction.transAccountId,
    );

    return Center(
      child: SingleChildScrollView(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _controller.categoryId$,
              builder: (context, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Account Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AccountRow(
                          account: account,
                          size: 24,
                        ),
                      ],
                    ),
                    // Amount Value
                    BasicTextFormField(
                      initialValue: _controller.amount.text,
                      readOnly: true,
                      labelText: locale.transPageAmount,
                      style: AppTextStyles.textStyleBold18.copyWith(
                        color: widget.transaction.transValue < 0
                            ? customColors.minusred
                            : customColors.lowgreen,
                      ),
                      suffixIcon: ExcludeSemantics(
                        child: widget.transaction.transValue >= 0
                            ? const Icon(Icons.thumb_up)
                            : const Icon(Icons.thumb_down),
                      ),
                    ),
                    // Description
                    AutocompleteTextFormField(
                      capitalization: TextCapitalization.sentences,
                      labelText: locale.transPageDescription,
                      controller: _controller.descriptionController,
                      suggestions:
                          _homePageController.cacheDescriptions.keys.toList(),
                      onEditingComplete: _controller.setCategoryByDescription,
                    ),
                    // Category
                    CategoryDropdownFormField(
                      readOnly: false,
                      removeTransfer: false,
                      hintText: locale.transPageCategoryHint,
                      labelText: locale.transPageCategory,
                      controller: _controller.categoryController,
                      suffixIcon: InkWell(
                        onTap: addCategoryAction,
                        child: Ink(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                      onChanged: _controller.setCategoryByName,
                    ),
                    // TransferAccount
                    if (_controller.isTransfer)
                      DestinyAccountDropdownForm(
                        globalKey: _destinyKey,
                        originAccountId: _controller.originAccountId,
                        destinyAccountId: _controller.destinyAccountId,
                        hintText: locale.transPageSelectAccTransfer,
                        labelText: locale.transPageAccTransfer,
                        accountIdSelected: _controller.setDestinyAccountId,
                      ),
                    // Date x Time
                    Semantics(
                      label: locale.transPageNewSelectDate,
                      child: DateTimePickerForm(
                        controller: _controller.dateController,
                        labelText: locale.transPageDate,
                        enable: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ButtonBar(
                      children: [
                        ListenableBuilder(
                          listenable: _controller.categoryId$,
                          builder: (context, _) => FilledButton(
                            onPressed: _controller.categoryId != null
                                ? _navigatorPopOk
                                : null,
                            child: Text(
                              locale.genericAdd,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, ButtonPress.skip),
                          child: Text(locale.genericSkip),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, ButtonPress.cancel),
                          child: Text(locale.genericCancel),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
