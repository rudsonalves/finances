import 'package:flutter/material.dart';

import '../../common/admob/admob_google.dart';
import '../../locator.dart';
import '../account/account_controller.dart';
import '../account/widgets/add_account_page.dart';
import '../categories/categories_controller.dart';
import '../categories/categories_page.dart';
import '../categories/widget/add_category_page.dart';
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
  final _pageController = PageController();
  final _homePageController = locator<HomePageController>();

  bool _floatAppButton = true;
  int _pageIndex = 0;
  void Function()? _addFunction;

  final AdmobIntersticial _admobIntersticial = AdmobIntersticial.instance;

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
    // 3 StatisticsPage(),
    _addFunction = addTransaction;
    if (adMobEnable) {
      _admobIntersticial.show();
    }
    setState(() {
      _pageIndex = page;
      _floatAppButton = (page != 3) ? true : false;
      if (page == 0) {
      } else if (page == 1) {
        _addFunction = addAccount;
      } else if (page == 2) {
        _addFunction = addCategory;
      }
      _pageController.jumpToPage(page);
      if (page == 0 && _homePageController.redraw) {
        _homePageController.makeRedraw();
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

  Future<void> addTransaction() async {
    await Navigator.pushNamed(context, AppRoute.transaction.name);
    await locator<HomePageController>().getTransactions().then(
          (value) => locator<BalanceCardController>().getBalance(),
        );
    locator<StatisticsController>().requestRecalculate();
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
    locator<StatisticsController>().requestRecalculate();
  }

  Future<void> addCategoryCallBak() async {
    await locator<CategoriesController>().getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          changeToMainPage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButton: _floatAppButton
            ? CustomFloatingActionButton(onPressed: _addFunction)
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            StatisticsPage(),
          ],
        ),
      ),
    );
  }
}
