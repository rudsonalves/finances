import 'package:flutter/material.dart';

import '../../../common/constants/app_constants.dart';
import '../../../common/extensions/money_masked_text_controller.dart';
import '../../../common/models/account_db_model.dart';
import '../../../common/models/ofx_trans_template_model.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../locator.dart';
import '../../../repositories/account/abstract_account_repository.dart';
import '../../../repositories/category/abstract_category_repository.dart';

class OfxTransactionController extends ChangeNotifier {
  OfxTransactionController();

  final _accountRepository = locator<AbstractAccountRepository>();
  final _categoryRepository = locator<AbstractCategoryRepository>();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _amount = getMoneyMaskedTextController(0.0);
  late TransactionDbModel _transaction;
  late OfxTransTemplateModel _ofxTransTemplate;
  final ValueNotifier<int?> categoryId$ = ValueNotifier(null);

  TextEditingController get categoryController => _categoryController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get dateController => _dateController;
  MoneyMaskedTextController get amount => _amount;
  int? get categoryId => categoryId$.value;
  TransactionDbModel get transaction => _transaction;
  OfxTransTemplateModel get ofxTransTemplate => _ofxTransTemplate;
  bool get isTransfer => _transaction.transCategoryId == TRANSFER_CATEGORY_ID;
  int get originAccountId => _transaction.transAccountId;
  int? get destinyAccountId => _ofxTransTemplate.transferAccountId;

  @override
  void dispose() {
    _categoryController.dispose();
    _amount.dispose();
    super.dispose();
  }

  void init({
    required int accountId,
    required TransactionDbModel transaction,
    required OfxTransTemplateModel ofxTransTemplate,
  }) {
    _accountRepository.init();
    _categoryRepository.init();
    categoryId$.value =
        transaction.transCategoryId > 0 ? transaction.transCategoryId : null;
    _transaction = transaction;
    _ofxTransTemplate = ofxTransTemplate;
    _descriptionController.text = transaction.transDescription;
    if (categoryId$.value != null) {
      _categoryController.text =
          _categoryRepository.getCategoryId(categoryId$.value!).categoryName;
    }
    _dateController.text = transaction.transDate.toIso8601String();
  }

  AccountDbModel getAccountById(int accountId) {
    final account = _accountRepository.accountsMap[accountId]!;
    return account;
  }

  void setCategoryByName(String? categoryName) {
    if (categoryName == null) return;
    categoryController.text = categoryName;
    setCategoryById(
      _categoryRepository.categoriesMap[categoryName]!.categoryId!,
    );
  }

  void setCategoryById(int categoryId) {
    categoryId$.value = categoryId;
    _transaction.transCategoryId = categoryId;
    _ofxTransTemplate.categoryId = categoryId;
  }

  void setTransactionDescription() {
    _transaction.transDescription = _descriptionController.text;
    _ofxTransTemplate.description = _descriptionController.text;
  }

  void setDestinyAccountId(int destinyAccountId) {
    _ofxTransTemplate.transferAccountId = destinyAccountId;
  }
}
