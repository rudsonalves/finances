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

import '../../locator.dart';
import '../account/account_controller.dart';
import '../account/widgets/add_account_page.dart';
import '../categories/categories_controller.dart';
import '../categories/categories_page.dart';
import '../categories/widget/add_category_page.dart';
import '../home_page/balance_card/balance_card_controller.dart';
import '../home_page/home_page.dart';
import '../account/account_page.dart';
import '../ofx_page/ofx_page.dart';
import '../ofx_page/ofx_page_controller.dart';
import '../statistics/statistic_controller.dart';
import '../statistics/statistics_page.dart';
import '../home_page/home_page_controller.dart';
import '../../common/widgets/custom_floating_action_button.dart';
import '../../common/widgets/custom_botton_navigator_bar.dart';
import '../transaction/transaction_dialog.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final _pageController = PageController();
  final _homePageController = locator<HomePageController>();
  final _balanceCardController = locator<BalanceCardController>();
  final _statisticsController = locator<StatisticsController>();
  final _ofxPageController = locator<OfxPageController>();

  bool _floatAppButton = true;
  int _pageIndex = 0;
  void Function()? _addFunction;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
    _addFunction = addTransaction;
    _floatAppButton = true;
  }

  void changePage(int page) {
    // 0 HomePage(),
    // 1 AccountPage(),
    // 2 BudgetPage(),
    // 3 OfxPage()
    // 4 StatisticsPage(),

    setState(() {
      _pageIndex = page;
      _floatAppButton = true;
      switch (page) {
        case 0:
          _addFunction = addTransaction;
          break;
        case 1:
          _addFunction = addAccount;
          break;
        case 2:
          _addFunction = addCategory;
          break;
        case 3:
          _addFunction = addOfxFile;
          _floatAppButton = true;
          break;
        case 4:
          _floatAppButton = false;
          _addFunction = null;
          break;
      }

      // Jump to new page
      _pageController.jumpToPage(page);
      // check for remake page
      if (page == 0 && _homePageController.redraw) {
        _homePageController.makeRedraw();
        _balanceCardController.makeRedraw();
      } else if (page == 3) {
        _statisticsController.makeRecalculated();
      }
    });
  }

  void changeToMainPage() {
    setState(() {
      _pageIndex = 0;
      _addFunction = addTransaction;
      _floatAppButton = true;
      _pageController.jumpToPage(0);
    });
  }

  // Add OfxFile
  Future<void> addOfxFile() async {
    try {
      final ofxPath = await _ofxPageController.pickAndValidateOfxFile(context);
      if (ofxPath == null) return;

      if (!mounted) return;
      final ofx = await _ofxPageController.processOfxFile(context, ofxPath);
      if (ofx == null) return;

      if (!mounted) return;
      await _ofxPageController.handleOfxImport(
        context,
        ofx: ofx,
        ofxPath: ofxPath,
      );

      _ofxPageController.ofxFileRegister();
    } catch (err) {
      if (!mounted) return;
      await _ofxPageController.showUnexpectedErrorMessage(context);
    }
  }

  Future<void> addTransaction() async {
    final added = await TransactionDialog.showTransactionDialog(context);
    if (added) {
      locator<HomePageController>().getTransactions().then(
            (value) => locator<BalanceCardController>().getBalance(),
          );
      _statisticsController.recalculate();
    }
  }

  Future<void> addAccount() async {
    await showDialog(
      context: context,
      builder: (context) => const AddAccountPage(),
    );
    locator<AccountController>().getAllBalances();
  }

  Future<void> addCategory() async {
    await showAdaptiveDialog(
      context: context,
      builder: (context) => AddCategoryPage(
        callBack: addCategoryCallBak,
      ),
    );
    _statisticsController.recalculate();
  }

  Future<void> addCategoryCallBak() async {
    await locator<CategoriesController>().getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _pageIndex != 0 ? false : true,
      onPopInvokedWithResult: (_, __) => changeToMainPage(),
      child: Scaffold(
        floatingActionButton: _floatAppButton
            ? CustomFloatingActionButton(
                onPressed: _addFunction,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: CustomBottomNavigatorBar(
          page: _pageIndex,
          floatAppButton: _floatAppButton,
          changePage: changePage,
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [
            HomePage(),
            AccountPage(),
            CategoriesPage(),
            OfxPage(),
            StatisticsPage(),
          ],
        ),
      ),
    );
  }
}
