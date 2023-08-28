import 'package:flutter/material.dart';

import '../../../features/category/category_page.dart';
import '../../../features/home_page_view/home_page_view.dart';
import '../../../features/onboarding/onboarding_page.dart';
import '../../../features/sign_in/sign_in_page.dart';
import '../../../features/sign_up/sign_up_page.dart';
import '../../../features/splash/splash_page.dart';
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
  static const Route category = Route(
    name: '/category',
    page: CategoryPage(),
  );
  static const Route transaction = Route(
    name: '/transaction',
    page: TransactionPage(),
  );
}
