import 'package:flutter/material.dart';

import '../../../features/account/account_page.dart';
import '../../../features/budget/budget_page.dart';
import '../../../features/budget/widget/add_category_page.dart';
import '../../../features/home_page/home_page.dart';
import '../../../features/home_page_view/home_page_view.dart';
import '../../../features/onboarding/onboarding_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/sign_in/sign_in_page.dart';
import '../../../features/sign_up/sign_up_page.dart';
import '../../../features/splash/splash_page.dart';
import '../../../features/statistics/statistics_page.dart';
import '../../../features/transaction/transaction_page.dart';

class Route {
  final String name;
  final Widget page;

  const Route({
    required this.name,
    required this.page,
  });
}

class AppRoute {
  AppRoute._();

  static const Route onboard = Route(
    name: '/',
    page: OnboardingPage(),
  );
  static const Route home = Route(
    name: '/home',
    page: HomePageView(),
  );
  static const Route signIn = Route(
    name: '/sign_in',
    page: SignInPage(),
  );
  static const Route signUp = Route(
    name: '/sign_up',
    page: SignUpPage(),
  );
  static const Route splash = Route(
    name: '/splash',
    page: SplashPage(),
  );
  static const Route transaction = Route(
    name: '/transaction',
    page: TransactionPage(),
  );
  static const Route settings = Route(
    name: '/settings',
    page: SettingsPage(),
  );
  static const Route homePage = Route(
    name: '/home_page',
    page: HomePage(),
  );
  static const Route statisticsPage = Route(
    name: '/statistics_page',
    page: StatisticsPage(),
  );
  static const Route accountPage = Route(
    name: '/account_page',
    page: AccountPage(),
  );
  static const Route budgetPage = Route(
    name: '/budget_page',
    page: BudgetPage(),
  );
  static const Route addCategoryPage = Route(
    name: '/add_category_page',
    page: AddCategoryPage(),
  );
}
