import 'package:finances/common/current_models/current_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../common/models/account_db_model.dart';
import '../../common/widgets/account_dropdown_form_field.dart';
import '../../locator.dart';
import '../../repositories/account/account_repository.dart';
import '../../services/database/managers/transfers_manager.dart';
import '../budget/budget_controller.dart';
import '../budget/widget/add_budget_dialog.dart';
import './transaction_controller.dart';
import '../../common/models/extends_date.dart';
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
import '../../repositories/category/category_repository.dart';
import '../../common/widgets/category_dropdown_form_field.dart';
import '../../common/widgets/autocomplete_text_form_field.dart';
import '../../common/extensions/money_masked_text_controller.dart';
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
  final _amountController = getMoneyMaskedTextController(0.0);
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _accountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _focusNodeBasicTextFormField = FocusNode();
  bool _income = false;

  final _controller = locator.get<TransactionController>();
  final _categoryRepository = locator.get<CategoryRepository>();
  int _categoryId = 0;

  @override
  void initState() {
    super.initState();
    _controller.init();

    _focusNodeBasicTextFormField.requestFocus();

    if (widget.transaction != null) {
      _amountController.text =
          widget.transaction!.transValue.toStringAsFixed(2);
      _descController.text = widget.transaction!.transDescription;
      _dateController.text = widget.transaction!.transDate.toIso8601String();
      _categoryController.text = _categoryRepository
          .getCategoryId(
            widget.transaction!.transCategoryId,
          )
          .categoryName;
      _income = widget.transaction!.transValue >= 0;
      _controller.getTransferAccountName(
        transaction: widget.transaction!,
        accountController: _accountController,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _focusNodeBasicTextFormField.dispose();
  }

  void cancelAction() {
    Navigator.pop(context);
  }

  void addAction() async {
    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();
    if (valit) {
      double value = _amountController.numberValue;
      value = _income ? value : -value;

      AccountDbModel? account1;
      if (_accountController.text.isNotEmpty) {
        int? accountId = locator
            .get<AccountRepository>()
            .accountIdByName(_accountController.text);
        if (accountId == null) {
          throw Exception('transactionPage: AccountId return null');
        }
        account1 = locator.get<AccountRepository>().accountsMap[accountId];
      }

      final TransactionDbModel transaction = TransactionDbModel(
        transId: widget.transaction?.transId,
        // widget.transaction != null ? widget.transaction!.transId : null,
        transDescription: _descController.text,
        transCategoryId: _categoryRepository.getIdByName(
          _categoryController.text,
        ),
        transValue: value,
        transStatus: TransStatus.transactionNotChecked,
        transTransferId: null,
        transDate: ExtendedDate.parse(_dateController.text),
      );

      if (account1 != null) {
        if (transaction.transId == null) {
          await TransfersManager.addTransfer(
            transaction0: transaction,
            account1: account1,
          );

          if (!mounted) return;
          Navigator.pop(context);
        } else {
          await TransfersManager.updateTransfer(transaction0: transaction);

          if (!mounted) return;
          Navigator.pop(context);
        }
      } else {
        if (transaction.transId == null) {
          await _controller.addTransactions(transaction);

          if (!mounted) return;
          Navigator.pop(context);
        } else {
          await _controller.updateTransactions(transaction);

          if (!mounted) return;
          Navigator.pop(context);
        }
      }
    }
  }

  void addCategoryAction() async {
    await showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        callBack: addCategoryCallBak,
      ),
    );
    setState(() {});
  }

  Future<void> addCategoryCallBak() async {
    await locator.get<BudgetController>().getAllCategories();
  }

  void changeState(bool state) {
    setState(() {
      _income = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final transValidator = TransactionValidator(locale);
    final homePageController = locator.get<HomePageController>();
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final currentAccount = locator.get<CurrentAccount>();

    if (widget.transaction != null) {
      _categoryId = widget.transaction!.transCategoryId;
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
          onPressed: () => Navigator.pop(context),
        ),
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
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  currentAccount.accountName,
                                  style: AppTextStyles.textStyleBold18.copyWith(
                                    color: primary,
                                  ),
                                ),
                              ),
                              RowOfTwoBottons(
                                income: _income,
                                changeState: changeState,
                              ),
                              const SizedBox(height: 4),
                              // Amount
                              BasicTextFormField(
                                labelText: locale.transPageAmount,
                                style: AppTextStyles.textStyleBold16.copyWith(
                                  color: !_income
                                      ? customColors.minusred
                                      : customColors.lowgreen,
                                ),
                                validator: transValidator.amountValidator,
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                focusNode: _focusNodeBasicTextFormField,
                                suffixIcon: ExcludeSemantics(
                                  child: IconButton(
                                    tooltip: _income
                                        ? locale.rowOfTwoBottonsIncome
                                        : locale.rowOfTwoBottonsExpense,
                                    autofocus: false,
                                    icon: _income
                                        ? const Icon(Icons.thumb_up)
                                        : const Icon(Icons.thumb_down),
                                    onPressed: () => changeState(!_income),
                                  ),
                                ),
                              ),
                              // Description
                              AutocompleteTextFormField(
                                capitalization: TextCapitalization.sentences,
                                labelText: locale.transPageDescription,
                                validator: transValidator.descriptionValidator,
                                controller: _descController,
                                suggestions: homePageController
                                    .cacheDescriptions.keys
                                    .toList(),
                                onEditingComplete: (description) {
                                  int? categoryId = homePageController
                                      .cacheDescriptions[description];
                                  if (categoryId != null) {
                                    final cat = locator
                                        .get<CategoryRepository>()
                                        .categories
                                        .firstWhere(
                                          (category) =>
                                              category.categoryId == categoryId,
                                        );
                                    _categoryController.text = cat.categoryName;
                                    setState(() {
                                      _categoryId = categoryId;
                                      _categoryController.text =
                                          cat.categoryName;
                                    });
                                  }
                                },
                              ),
                              // Category
                              CategoryDropdownFormField(
                                hintText: locale.transPageCategoryHint,
                                labelText: locale.transPageCategory,
                                controller: _categoryController,
                                validator: transValidator.categoryValidator,
                                suffixIcon: IconButton(
                                  tooltip: locale.transPageNewCategory,
                                  onPressed: addCategoryAction,
                                  icon: const Icon(Icons.add),
                                ),
                                onChanged: (categoryName) {
                                  if (categoryName != null) {
                                    final category = locator
                                        .get<CategoryRepository>()
                                        .categoriesMap[categoryName];
                                    if (category != null) {
                                      setState(() {
                                        _categoryId = category.categoryId!;
                                        _income = category.categoryIsIncome;
                                      });
                                    }
                                  }
                                },
                              ),
                              if (_categoryId == 1)
                                AccountDropdownFormField(
                                  hintText: locale.transPageSelectAccTransfer,
                                  labelText: locale.transPageAccTransfer,
                                  controller: _accountController,
                                ),
                              // Date x Time
                              Semantics(
                                label: locale.transPageNewSelectDate,
                                child: DateTimePickerForm(
                                  controller: _dateController,
                                  labelText: locale.transPageDate,
                                ),
                              ),
                              const SizedBox(height: 20),
                              AddCancelButtons(
                                addLabel: widget.addTransaction
                                    ? locale.transPageButtonAdd
                                    : locale.transPageButtonUpdate,
                                addCallback: addAction,
                                cancelCallback: cancelAction,
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
