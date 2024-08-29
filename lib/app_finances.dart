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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './locator.dart';
import './common/constants/routes/app_route.dart';
import './common/current_models/current_theme.dart';
import './common/current_models/current_language.dart';
import './common/constants/themes/colors/custom_color.g.dart';
import './common/constants/themes/colors/color_schemes.g.dart';

class AppFinances extends StatelessWidget {
  const AppFinances({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = locator<CurrentLanguage>();
    final currentTheme = locator<CurrentTheme>();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          lightCustomColors = lightCustomColors.harmonized(lightScheme);

          // Repeat for the dark color scheme.
          darkScheme = darkDynamic.harmonized();
          darkCustomColors = darkCustomColors.harmonized(darkScheme);
        } else {
          // Otherwise, use fallback schemes.
          lightScheme = lightColorScheme;
          darkScheme = darkColorScheme;
        }

        final localeName = Platform.localeName;
        currentLanguage.setFromLocaleCode(localeName);

        return AnimatedBuilder(
          animation: Listenable.merge([
            currentTheme.themeMode$,
            currentLanguage.locale$,
          ]),
          builder: (context, _) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: currentLanguage.locale,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightScheme,
                extensions: [lightCustomColors],
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkScheme,
                extensions: [darkCustomColors],
              ),
              themeMode: currentTheme.themeMode,
              debugShowCheckedModeBanner: false,
              initialRoute: AppRoute.splash.name,
              routes: {
                AppRoute.onboard.name: (context) => AppRoute.onboard.page,
                AppRoute.home.name: (context) => AppRoute.home.page,
                AppRoute.signIn.name: (context) => AppRoute.signIn.page,
                AppRoute.signUp.name: (context) => AppRoute.signUp.page,
                AppRoute.splash.name: (context) => AppRoute.splash.page,
                AppRoute.settings.name: (context) => AppRoute.settings.page,
                AppRoute.homePage.name: (context) => AppRoute.homePage.page,
                AppRoute.statisticsPage.name: (context) =>
                    AppRoute.statisticsPage.page,
                AppRoute.accountPage.name: (context) =>
                    AppRoute.accountPage.page,
                AppRoute.budgetPage.name: (context) => AppRoute.budgetPage.page,
                AppRoute.aboutPage.name: (context) => AppRoute.aboutPage.page,
                AppRoute.ofxPage.name: (context) => AppRoute.ofxPage.page,
              },
            );
          },
        );
      },
    );
  }
}
