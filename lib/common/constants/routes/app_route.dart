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

import '../../../features/about/about_page.dart';
import '../../../features/account/account_page.dart';
import '../../../features/categories/categories_page.dart';
import '../../../features/home_page/home_page.dart';
import '../../../features/home_page_view/home_page_view.dart';
import '../../../features/ofx_page/ofx_page.dart';
import '../../../features/onboarding/onboarding_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/sign_in/sign_in_page.dart';
import '../../../features/sign_up/sign_up_page.dart';
import '../../../features/splash/splash_page.dart';
import '../../../features/statistics/statistics_page.dart';

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
    page: CategoriesPage(),
  );
  static const Route aboutPage = Route(
    name: '/about',
    page: AboutPage(),
  );
  static const Route ofxPage = Route(
    name: '/ofx_page',
    page: OfxPage(),
  );
}
