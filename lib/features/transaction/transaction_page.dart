import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/constants/themes/colors/custom_color.g.dart';
import '../../common/current_models/current_account.dart';
import '../../common/models/account_db_model.dart';
import '../../common/models/category_db_model.dart';
import '../../common/widgets/account_dropdown_form_field.dart';
import '../../common/widgets/simple_spin_box_field.dart';
import '../../locator.dart';
import '../../manager/transfer_manager.dart';
import '../../repositories/account/abstract_account_repository.dart';
import '../categories/categories_controller.dart';
import '../categories/widget/add_category_page.dart';
import '../help_manager/main_manager.dart';
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
import '../../repositories/category/abstract_category_repository.dart';
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
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _installments = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _focusNodeBasicTextFormField = FocusNode();

  final _originAccount = ValueNotifier<AccountDbModel>(
    locator<CurrentAccount>(),
  );
  final _destinationAccountId = ValueNotifier<int?>(null);
  final _accountsMap = locator<AbstractAccountRepository>().accountsMap;

  bool _income = false;
  bool _repeat = false;

  final _controller = locator<TransactionController>();
  final _categoryRepository = locator<AbstractCategoryRepository>();
  final _homePageController = locator<HomePageController>();
  int? _categoryId;

  final _originKey = GlobalKey<FormFieldState<int>>();
  final _destinyKey = GlobalKey<FormFieldState<int>>();

  @override
  void initState() {
    super.initState();
    _controller.init();

    _focusNodeBasicTextFormField.requestFocus();

    if (widget.transaction != null) {
      _amountController.text =
          widget.transaction!.transValue.toStringAsFixed(2);
      _descriptionController.text = widget.transaction!.transDescription;
      _dateController.text = widget.transaction!.transDate.toIso8601String();
      _categoryController.text = _categoryRepository
          .getCategoryId(
            widget.transaction!.transCategoryId,
          )
          .categoryName;
      _income = widget.transaction!.transValue >= 0;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _installments.dispose();
    _originAccount.dispose();
    _destinationAccountId.dispose();
    _focusNodeBasicTextFormField.dispose();
    super.dispose();
  }

  void cancelTransactionsAction() {
    Navigator.pop(context, false);
  }

  bool get isTransfer => _categoryId == 1;

  void addTransactionsAction() async {
    bool valit =
        _formKey.currentState != null && _formKey.currentState!.validate();
    if (isTransfer) {
      valit = valit &&
          _destinyKey.currentState != null &&
          _destinyKey.currentState!.validate();
    }
    if (valit) {
      double value = _amountController.numberValue;
      value = _income ? value.abs() : -value.abs();

      // get destination account
      AccountDbModel? destinyAccount;

      if (_controller.destAccountId != null) {
        int? accountId = _controller.destAccountId;
        if (accountId == null) {
          throw Exception('transactionPage: AccountId return null');
        }
        destinyAccount = _accountsMap[accountId];
      }

      // Create transaction
      final TransactionDbModel transaction = TransactionDbModel(
        transId: widget.transaction?.transId,
        // transBalanceId: xxx,
        transAccountId: _originAccount.value.accountId!,
        transDescription: _descriptionController.text,
        transCategoryId: _categoryRepository.getIdByName(
          _categoryController.text,
        ),
        transValue: value,
        transStatus: TransStatus.transactionNotChecked,
        transTransferId: null,
        transDate: ExtendedDate.parse(_dateController.text),
      );

      int? numberOfRepetitions;
      if (_repeat) {
        numberOfRepetitions = int.parse(
          _installments.text.replaceAll('x ', ''),
        );
      }

      final navigator = Navigator.of(context);
      // Check for Transfer
      if (destinyAccount != null) {
        if (transaction.transId == null) {
          if (_repeat) {
            ExtendedDate date = transaction.transDate;
            for (int count = 1; count <= numberOfRepetitions!; count++) {
              String label = '($count/$numberOfRepetitions)';
              final newTrans = transaction.copy();
              if (count > 1) {
                date = date.nextMonth();
              }
              newTrans.transDescription = '${newTrans.transDescription} $label';
              newTrans.transDate = date;
              await TransferManager.addTranfer(
                transOrigin: newTrans,
                accountDestinyId: destinyAccount.accountId!,
              );
            }
          } else {
            await TransferManager.addTranfer(
              transOrigin: transaction,
              accountDestinyId: destinyAccount.accountId!,
            );
          }
          navigator.pop(true);
        } else {
          await TransferManager.updateTransfer(
            transOrigin: transaction,
            accountDestinyId: destinyAccount.accountId!,
          );

          navigator.pop(true);
        }
      } else {
        if (transaction.transId == null) {
          if (_repeat) {
            ExtendedDate date = transaction.transDate;
            for (int count = 1; count <= numberOfRepetitions!; count++) {
              String label = '($count/$numberOfRepetitions)';
              final newTrans = transaction.copy();
              if (count > 1) {
                date = date.nextMonth();
              }
              newTrans.transDescription = '${newTrans.transDescription} $label';
              newTrans.transDate = date;
              await _controller.addTransactions(
                transaction: newTrans,
                account: _originAccount.value,
              );
            }
          } else {
            await _controller.addTransactions(
              transaction: transaction,
              account: _originAccount.value,
            );
          }
          navigator.pop(true);
        } else {
          await _controller.updateTransactions(
            transaction: transaction,
            account: _originAccount.value,
          );
          navigator.pop(true);
        }
      }
    }
  }

  void addCategoryAction() async {
    final CategoryDbModel? newCategory = await showDialog(
      context: context,
      builder: (context) => AddCategoryPage(
        callBack: addCategoryCallBak,
      ),
    );

    if (newCategory != null) {
      _categoryId = newCategory.categoryId;
      _categoryController.text = newCategory.categoryName;
    }

    setState(() {});
  }

  void editCategoryAction() async {
    if (_categoryId != null) {
      final category = _categoryRepository.getCategoryId(_categoryId!);
      await showDialog(
        context: context,
        builder: (context) => AddCategoryPage(
          editCategory: category,
          callBack: addCategoryCallBak,
        ),
      );
    }
  }

  Future<void> addCategoryCallBak() async {
    await locator<CategoriesController>().getAllCategories();
  }

  void changeState(bool state) {
    setState(() {
      _income = state;
    });
  }

  void toogleRepeat() {
    setState(() {
      _repeat = !_repeat;
    });
  }

  void selectCategory(categoryName) {
    if (categoryName != null) {
      final category = _categoryRepository.categoriesMap[categoryName];
      if (category != null) {
        setState(() {
          _categoryId = category.categoryId!;
          _income = category.categoryIsIncome;
        });
      }
    }
  }

  void onEditDescription(description) {
    int? categoryId = _homePageController.cacheDescriptions[description];
    if (categoryId != null) {
      final category = _categoryRepository.getCategoryId(categoryId);
      _categoryController.text = category.categoryName;
      setState(() {
        _categoryId = categoryId;
        _categoryController.text = category.categoryName;
      });
    }
  }

  PopupMenuButton<int> accountPopupMenuButton(
    AppLocalizations locale,
    Color primary,
  ) {
    return PopupMenuButton<int>(
      key: _originKey,
      tooltip: locale.cardBalanceMenuTip,
      onSelected: setOriginAccountId,
      itemBuilder: (BuildContext context) {
        return _accountsMap.values.map((account) {
          return PopupMenuItem(
            value: account.accountId,
            child: Row(
              children: [
                account.accountIcon.iconWidget(size: 16),
                const SizedBox(width: 8),
                Text(account.accountName),
              ],
            ),
          );
        }).toList();
      },
      child: ListenableBuilder(
          listenable: _originAccount,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _originAccount.value.accountIcon.iconWidget(size: 24),
                const SizedBox(width: 6),
                Text(
                  _originAccount.value.accountName,
                  maxLines: 1,
                  style: AppTextStyles.textStyleSemiBold20
                      .copyWith(color: primary),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: primary,
                ),
              ],
            );
          }),
    );
  }

  void setOriginAccountId(int id) {
    if (id == _destinationAccountId.value) {
      _destinationAccountId.value = null;
      _controller.setDestAccountId(null);
      _destinyKey.currentState?.reset();
    }

    _controller.setOriginAccount(id);
    _originAccount.value = _accountsMap[id]!;
  }

  void setDestinationAccountId(int id) {
    _controller.setDestAccountId(id);
    _destinationAccountId.value = id;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final transValidator = TransactionValidator(locale);
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

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
                        if (_controller.destAccountId != null) {
                          _destinationAccountId.value =
                              _controller.destAccountId!;
                        }

                        return Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                // Account Selection
                                child: accountPopupMenuButton(locale, primary),
                              ),
                              // Income Buttons
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
                                controller: _descriptionController,
                                suggestions: _homePageController
                                    .cacheDescriptions.keys
                                    .toList(),
                                onEditingComplete: onEditDescription,
                              ),
                              // Category
                              CategoryDropdownFormField(
                                hintText: locale.transPageCategoryHint,
                                labelText: locale.transPageCategory,
                                controller: _categoryController,
                                validator: transValidator.categoryValidator,
                                suffixIcon: InkWell(
                                  onTap: addCategoryAction,
                                  onLongPress: editCategoryAction,
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                                onChanged: selectCategory,
                              ),
                              // Destiny Account
                              if (isTransfer)
                                ListenableBuilder(
                                  listenable: _originAccount,
                                  builder: (context, _) {
                                    return AccountDropdownFormField(
                                      globalKey: _destinyKey,
                                      originAccountId:
                                          _originAccount.value.accountId!,
                                      destinationAccountId:
                                          _destinationAccountId.value,
                                      validate: transValidator
                                          .accountForTransferValidator,
                                      hintText:
                                          locale.transPageSelectAccTransfer,
                                      labelText: locale.transPageAccTransfer,
                                      accountIdSelected:
                                          setDestinationAccountId,
                                    );
                                  },
                                ),
                              // Date x Time
                              Semantics(
                                label: locale.transPageNewSelectDate,
                                child: DateTimePickerForm(
                                  controller: _dateController,
                                  labelText: locale.transPageDate,
                                ),
                              ),
                              // Installments - Repeat Monthly
                              TextButton.icon(
                                onPressed:
                                    widget.addTransaction ? toogleRepeat : null,
                                icon: _repeat
                                    ? const Icon(Icons.task_alt)
                                    : const Icon(Icons.radio_button_unchecked),
                                label: Text(
                                  locale.transactionRepeatMonthly,
                                  style: AppTextStyles.textStyleSemiBold16,
                                ),
                              ),
                              // Installments - Repeat times
                              if (_repeat)
                                SimpleSpinBoxField(
                                  labelText: locale.transactionRepeatTimes,
                                  style: AppTextStyles.textStyleBold16.copyWith(
                                    color: primary,
                                  ),
                                  controller: _installments,
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
                                cancelCallback: cancelTransactionsAction,
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
