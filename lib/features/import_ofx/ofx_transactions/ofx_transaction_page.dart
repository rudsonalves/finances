import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/constants/themes/app_text_styles.dart';
import '../../../common/models/category_db_model.dart';
import '../../../common/models/transaction_db_model.dart';
import '../../../common/widgets/app_top_border.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../locator.dart';
import '../../categories/categories_controller.dart';
import '../../categories/widget/add_category_page.dart';
import '../../help_manager/main_manager.dart';

class OfxTransactionPage extends StatefulWidget {
  final bool addTransaction;
  final TransactionDbModel? transaction;

  const OfxTransactionPage({
    super.key,
    this.addTransaction = true,
    this.transaction,
  });

  @override
  State<OfxTransactionPage> createState() => _OfxTransactionPageState();
}

class _OfxTransactionPageState extends State<OfxTransactionPage> {
  final _focusNodeBasicTextFormField = FocusNode();
  // final _homePageController = locator<HomePageController>();
  // final _controller = OfxTransactionController();
  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    locator<CategoriesController>().init();

    // _controller.init(widget.transaction);

    _focusNodeBasicTextFormField.requestFocus();

    if (widget.transaction != null) {
      // _controller.setIncome(widget.transaction!.transValue >= 0);
    }
  }

  @override
  void dispose() {
    // _controller.dispose();
    _focusNodeBasicTextFormField.dispose();
    super.dispose();
  }

  void addTransactionsAction() async {
    // bool valit =
    //     _formKey.currentState != null && _formKey.currentState!.validate();

    // if (valit) {
    //   _controller.addTransactionsAction(
    //     context,
    //     income: _controller.income,
    //     repeat: _controller.repeat,
    //   );
    // }
  }

  void addCategoryAction() async {
    final CategoryDbModel? newCategory = await showDialog(
      context: context,
      builder: (context) => AddCategoryPage(
        callBack: locator<CategoriesController>().getAllCategories,
      ),
    );

    if (newCategory != null) {
      // _controller.setCategoryByModel(newCategory);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    if (widget.transaction != null) {
      // _controller.setCategoryById(widget.transaction!.transCategoryId);
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('kkk'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
