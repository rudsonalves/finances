import 'package:flutter/material.dart';

import '../../locator.dart';
import '../account/account_controller.dart';
import '../account/widgets/statefull_add_account_dialog.dart';
import '../budget/budget_controller.dart';
import '../budget/budget_page.dart';
import '../budget/widget/add_budget_dialog.dart';
import '../home_page/home_page.dart';
import '../account/account_page.dart';
import '../statistics/statistic_controller.dart';
import '../statistics/statistics_page.dart';
import '../home_page/home_page_controller.dart';
import '../../common/constants/routes/app_route.dart';
import '../../common/widgets/custom_floating_action_button.dart';
import '../../common/widgets/custom_botton_navigator_bar.dart';
import '../home_page/balance_card/balance_card_controller.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final PageController _pageController = PageController();
  bool _floatAppButton = true;
  int _pageIndex = 0;
  bool _canPop = true;
  void Function()? _addFunction;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void changePage(int page) {
    setState(() {
      _pageIndex = page;
      _floatAppButton = (page != 1) ? true : false;
      _canPop = false;
      if (page == 0) {
        _canPop = true;
        _addFunction = addTransaction;
      } else if (page == 2) {
        _addFunction = addAccount;
      } else if (page == 3) {
        _addFunction = addCategory;
      }
      _pageController.jumpToPage(page);
    });
    if (page == 1) {
      final statController = locator.get<StatisticsController>();
      if (statController.redraw) {
        statController.getStatistics(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
    _canPop = true;
    _addFunction = addTransaction;
    _floatAppButton = true;
  }

  void changeToMainPage() {
    setState(() {
      _pageIndex = 0;
      _canPop = true;
      _addFunction = addTransaction;
      _floatAppButton = true;
      _pageController.jumpToPage(0);
    });
  }

  Future<void> addTransaction() async {
    await Navigator.pushNamed(context, AppRoute.transaction.name);
    await locator.get<HomePageController>().getTransactions().then(
          (value) => locator.get<BalanceCardController>().getBalance(),
        );
    locator.get<StatisticsController>().requestRedraw();
  }

  Future<void> addAccount() async {
    await statefullAddAccountDialog(context);
    locator.get<AccountController>().getAllBalances();
  }

  Future<void> addCategory() async {
    await showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        callBack: addCategoryCallBak,
      ),
    );
  }

  Future<void> addCategoryCallBak() async {
    await locator.get<BudgetController>().getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (_pageIndex != 0) {
          changeToMainPage();
        }
      },
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [
            HomePage(),
            StatisticsPage(),
            AccountPage(),
            BudgetPage(),
          ],
        ),
        floatingActionButton: _floatAppButton
            ? CustomFloatingActionButton(onPressed: _addFunction)
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomBottomNavigatorBar(
          page: _pageIndex,
          floatAppButton: _floatAppButton,
          changePage: changePage,
        ),
      ),
    );
  }
}
