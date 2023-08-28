import 'package:flutter/material.dart';

import '../../locator.dart';
import '../account/account_controller.dart';
import '../account/widgets/statefull_add_account_dialog.dart';
import '../home_page/home_page.dart';
import '../account/account_page.dart';
import '../settings/settings_page.dart';
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
  void Function()? _addFunction;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void changePage(int page) {
    setState(() {
      _pageIndex = page;
      _floatAppButton = (page == 0 || page == 2) ? true : false;
      if (page == 0) {
        _addFunction = addTransaction;
      } else if (page == 2) {
        _addFunction = addAccount;
      }
      _pageController.jumpToPage(page);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
    _addFunction = addTransaction;
    _floatAppButton = true;
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
    await locator.get<HomePageController>().getTransactions().then(
          (value) => locator.get<BalanceCardController>().getBalance(),
        );
    locator.get<StatisticsController>().requestRedraw();
  }

  Future<void> addAccount() async {
    await statefullAddAccountDialog(context);
    locator.get<AccountController>().getAllBalances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          const HomePage(),
          StatisticsPage(backPage: changeToMainPage),
          AccountPage(backPage: changeToMainPage),
          SettingsPage(backPage: changeToMainPage),
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
    );
  }
}
