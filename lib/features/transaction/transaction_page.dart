import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../common/models/category_db_model.dart';
import 'widget/destiny_account_dropdown_form.dart';
import '../../common/widgets/simple_spin_box_field.dart';
import '../../locator.dart';
import '../categories/categories_controller.dart';
import '../categories/widget/add_category_page.dart';
import '../help_manager/main_manager.dart';
import './transaction_controller.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/row_of_two_bottons.dart';
import '../../common/widgets/add_cancel_buttons.dart';
import '../../common/models/transaction_db_model.dart';
import '../../common/widgets/date_time_picker_form.dart';
import '../../common/widgets/basic_text_form_field.dart';
import '../../common/validate/transaction_validator.dart';
import '../../features/transaction/transaction_state.dart';
import '../../features/home_page/home_page_controller.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/category_dropdown_form_field.dart';
import '../../common/widgets/autocomplete_text_form_field.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';

class TransactionPage extends StatefulWidget {
  final bool addTransaction;
  final TransactionDbModel? transaction;

  const TransactionPage({
    super.key,
    this.addTransaction = true,
    this.transaction,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _focusNodeBasicTextFormField = FocusNode();
  final _homePageController = locator<HomePageController>();

  bool _lockCategory = false;
  bool _removeTransfer = false;

  final _controller = TransactionController();

  final _formKey = GlobalKey<FormState>();
  final _originKey = GlobalKey<FormFieldState<int>>();
  final _destinyKey = GlobalKey<FormFieldState<int>>();

  @override
  void initState() {
    super.initState();
    locator<CategoriesController>().init();

    _controller.init(widget.transaction);

    _focusNodeBasicTextFormField.requestFocus();

    if (widget.transaction != null) {
      _controller.setIncome(widget.transaction!.transValue >= 0);

      if (widget.transaction!.transCategoryId == 1) {
        _lockCategory = true;
      } else {
        _removeTransfer = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNodeBasicTextFormField.dispose();
    super.dispose();
  }

  void addTransactionsAction() async {
    bool valit =
        _formKey.currentState != null && _formKey.currentState!.validate();
    if (_controller.isTransfer) {
      valit = valit &&
          _destinyKey.currentState != null &&
          _destinyKey.currentState!.validate();
    }
    if (valit) {
      _controller.addTransactionsAction(
        context,
        income: _controller.income,
        repeat: _controller.repeat,
      );
    }
  }

  void addCategoryAction() async {
    final CategoryDbModel? newCategory = await showDialog(
      context: context,
      builder: (context) => AddCategoryPage(
        callBack: locator<CategoriesController>().getAllCategories,
      ),
    );

    if (newCategory != null && !_lockCategory) {
      _controller.setCategoryByModel(newCategory);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final transValidator = TransactionValidator(locale);
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

    if (widget.transaction != null) {
      _controller.setCategoryById(widget.transaction!.transCategoryId);
    }

    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: true,
        title: Text(
          widget.addTransaction
              ? locale.transPageTitleAdd
              : locale.transPageTitleUpdate,
          style: AppTextStyles.textStyleSemiBold18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          IconButton(
            onPressed: () => managerTutorial(
              context,
              transactionsAddHelp,
            ),
            icon: const Icon(
              Icons.question_mark,
              size: 20,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            bottom: 0,
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
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // Transaction State Loading
                      if (_controller.state is TransactionStateLoading) {
                        return const CustomCircularProgressIndicator();
                      }

                      // Transaction State Success
                      if (_controller.state is TransactionStateSuccess) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                // Account Selection
                                child: PopupMenuButton<int>(
                                  key: _originKey,
                                  tooltip: locale.cardBalanceMenuTip,
                                  onSelected: _controller.setOriginAccountId,
                                  itemBuilder: (BuildContext context) {
                                    return _controller.accountsMap.values
                                        .map((account) {
                                      return PopupMenuItem(
                                        value: account.accountId,
                                        child: Row(
                                          children: [
                                            account.accountIcon
                                                .iconWidget(size: 16),
                                            const SizedBox(width: 8),
                                            Text(account.accountName),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _controller.originAccount.accountIcon
                                          .iconWidget(size: 24),
                                      const SizedBox(width: 6),
                                      Text(
                                        _controller.originAccount.accountName,
                                        maxLines: 1,
                                        style: AppTextStyles.textStyleSemiBold20
                                            .copyWith(color: primary),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Income Buttons
                              RowOfTwoBottons(
                                income: _controller.income,
                                changeState: _controller.setIncome,
                              ),
                              const SizedBox(height: 4),
                              // Amount
                              BasicTextFormField(
                                labelText: locale.transPageAmount,
                                style: AppTextStyles.textStyleBold16.copyWith(
                                  color: !_controller.income
                                      ? customColors.minusred
                                      : customColors.lowgreen,
                                ),
                                validator: transValidator.amountValidator,
                                controller: _controller.amount,
                                keyboardType: TextInputType.number,
                                focusNode: _focusNodeBasicTextFormField,
                                suffixIcon: ExcludeSemantics(
                                  child: IconButton(
                                    tooltip: _controller.income
                                        ? locale.rowOfTwoBottonsIncome
                                        : locale.rowOfTwoBottonsExpense,
                                    autofocus: false,
                                    icon: _controller.income
                                        ? const Icon(Icons.thumb_up)
                                        : const Icon(Icons.thumb_down),
                                    onPressed: _controller.toogleIncome,
                                  ),
                                ),
                              ),
                              // Description
                              AutocompleteTextFormField(
                                capitalization: TextCapitalization.sentences,
                                labelText: locale.transPageDescription,
                                validator: transValidator.descriptionValidator,
                                controller: _controller.description,
                                suggestions: _homePageController
                                    .cacheDescriptions.keys
                                    .toList(),
                                onEditingComplete:
                                    _controller.setCategoryByDescription,
                              ),
                              // Category
                              CategoryDropdownFormField(
                                lockCategory: _lockCategory,
                                removeTransfer: _removeTransfer,
                                hintText: locale.transPageCategoryHint,
                                labelText: locale.transPageCategory,
                                controller: _controller.category,
                                validator: transValidator.categoryValidator,
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
                              // Destiny Account
                              if (_controller.isTransfer)
                                DestinyAccountDropdownForm(
                                  globalKey: _destinyKey,
                                  originAccountId: _controller.originAccountId,
                                  destinyAccountId:
                                      _controller.destinyAccountId,
                                  validate: transValidator
                                      .accountForTransferValidator,
                                  hintText: locale.transPageSelectAccTransfer,
                                  labelText: locale.transPageAccTransfer,
                                  accountIdSelected:
                                      _controller.setDestinyAccountId,
                                ),
                              // Date x Time
                              Semantics(
                                label: locale.transPageNewSelectDate,
                                child: DateTimePickerForm(
                                  controller: _controller.date,
                                  labelText: locale.transPageDate,
                                ),
                              ),
                              // Installments - Repeat Monthly
                              TextButton.icon(
                                onPressed: widget.addTransaction
                                    ? _controller.toogleRepeat
                                    : null,
                                icon: _controller.repeat
                                    ? const Icon(Icons.task_alt)
                                    : const Icon(Icons.radio_button_unchecked),
                                label: Text(
                                  locale.transactionRepeatMonthly,
                                  style: AppTextStyles.textStyleSemiBold16,
                                ),
                              ),
                              // Installments - Repeat times
                              if (_controller.repeat)
                                SimpleSpinBoxField(
                                  labelText: locale.transactionRepeatTimes,
                                  style: AppTextStyles.textStyleBold16.copyWith(
                                    color: primary,
                                  ),
                                  controller: _controller.installments,
                                  minValue: 2,
                                  value: 2,
                                  maxValue: 12,
                                ),
                              const SizedBox(height: 20),
                              AddCancelButtons(
                                addLabel: widget.addTransaction
                                    ? locale.transPageButtonAdd
                                    : locale.transPageButtonUpdate,
                                addCallback: addTransactionsAction,
                                cancelCallback: () =>
                                    Navigator.pop(context, false),
                              ),
                            ],
                          ),
                        );
                      }

                      // Transaction State Error
                      if (_controller.state is TransactionStateError) {
                        return Text(locale.transPageError);
                      }
                      return Text(locale.transPageError);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
