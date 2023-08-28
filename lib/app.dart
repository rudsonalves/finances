import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './locator.dart';
import './common/constants/routes/app_route.dart';
import './common/models/transaction_db_model.dart';
import './common/current_models/current_theme.dart';
import './features/transaction/transaction_page.dart';
import './common/current_models/current_language.dart';
import './common/constants/themes/colors/custom_color.g.dart';
import './common/constants/themes/colors/color_schemes.g.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = locator.get<CurrentLanguage>();
    final currentTheme = locator.get<CurrentTheme>();

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
                AppRoute.category.name: (context) => AppRoute.category.page,
                AppRoute.transaction.name: (context) {
                  final Map<String, dynamic>? args = ModalRoute.of(context)!
                      .settings
                      .arguments as Map<String, dynamic>?;

                  if (args == null) {
                    return const TransactionPage();
                  } else {
                    final bool addTransaction = args['addTransaction'] ?? true;
                    final TransactionDbModel? transaction = args['transaction'];
                    return TransactionPage(
                      addTransaction: addTransaction,
                      transaction: transaction,
                    );
                  }
                },
              },
            );
          },
        );
      },
    );
  }
}
