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

import 'dart:developer';

import 'package:get_it/get_it.dart';

import './common/extensions/app_scale.dart';
import './common/models/categories_icons.dart';
import 'features/ofx_page/ofx_page_controller.dart';
import 'repositories/database/abstract_database_repository.dart';
import 'repositories/database/database_repository.dart';
import 'repositories/user/abstract_user_repository.dart';
import './features/splash/splash_controller.dart';
import './common/current_models/current_user.dart';
import './common/extensions/money_masked_text.dart';
import './features/sign_in/sign_in_controller.dart';
import './features/sign_up/sign_up_controller.dart';
import './common/current_models/current_theme.dart';
import 'common/current_models/current_account.dart';
import './services/authentication/auth_service.dart';
import './common/current_models/current_balance.dart';
import 'common/models/app_locale.dart';
import 'common/models/user_name_notifier.dart';
import 'features/account/account_controller.dart';
import 'features/categories/categories_controller.dart';
import 'features/statistics/statistic_card/statistic_card_controller.dart';
import 'features/statistics/statistic_controller.dart';
import 'repositories/account/abstract_account_repository.dart';
import './common/current_models/current_language.dart';
import './features/home_page/home_page_controller.dart';
import 'repositories/balance/abstract_balance_repository.dart';
import 'repositories/category/abstract_category_repository.dart';
import 'repositories/user/user_repository.dart';
import './features/transaction/transaction_controller.dart';
import './services/authentication/firebase_auth_service.dart';
import 'repositories/account/account_repository.dart';
import 'repositories/balance/balance_repository.dart';
import 'repositories/transaction/abstract_transaction_repository.dart';
import 'repositories/category/category_repository.dart';
import './features/home_page/balance_card/balance_card_controller.dart';
import 'repositories/transaction/transaction_repository.dart';
import 'common/constants/themes/app_icons.dart';
import 'common/models/icons_model.dart';
import 'repositories/icons/abstract_icons_repository.dart';
import 'repositories/icons/icons_repository.dart';
import 'repositories/transfer/transfer_repository.dart';
import 'repositories/transfer/abstract_transfer_repository.dart';
import 'store/database/database_manager.dart';

final locator = GetIt.instance;

void setupDependencies() {
  try {
    locator.registerSingleton<AuthService>(
      FirebaseAuthService(),
    );

    locator.registerSingleton<DatabaseManager>(DatabaseManager());

    locator.registerSingleton<AbstractDatabaseRepository>(
      DatabaseRepository(),
    );

    locator.registerLazySingleton<CurrentUser>(
      () => CurrentUser(),
    );

    locator.registerLazySingleton<CurrentAccount>(
      () => CurrentAccount(
          accountName: 'main',
          accountUserId: '0',
          accountIcon: IconModel(
            iconName: 'wallet',
            iconFontFamily: IconsFontFamily.MaterialIcons,
          )),
    );

    locator.registerLazySingleton<CurrentBalance>(
      () => CurrentBalance(),
    );

    locator.registerLazySingleton<CurrentTheme>(
      () => CurrentTheme(),
    );

    locator.registerLazySingleton<CurrentLanguage>(
      () => CurrentLanguage(),
    );

    locator.registerLazySingleton<CategoriesIcons>(
      () => CategoriesIcons(),
    );

    locator.registerLazySingleton<MoneyMaskedText>(
      () => MoneyMaskedText.getMoneyMaskedText(),
    );

    locator.registerLazySingleton<AppScale>(
      () => AppScale(),
    );

    locator.registerLazySingleton<AbstractUserRepository>(
      () => UserRepository(),
    );

    locator.registerLazySingleton<AbstractIconRepository>(
      () => IconsRepository(),
    );

    locator.registerLazySingleton<AbstractAccountRepository>(
      () => AccountRepository(),
    );

    locator.registerLazySingleton<AbstractCategoryRepository>(
      () => CategoryRepository(),
    );

    locator.registerLazySingleton<AbstractTransactionRepository>(
      () => TransactionRepository(),
    );

    locator.registerLazySingleton<AbstractTransferRepository>(
      () => TransferRepository(),
    );

    locator.registerLazySingleton<AbstractBalanceRepository>(
      () => BalanceRepository(),
    );

    locator.registerFactory<SignInController>(
      () => SignInController(
        locator<AuthService>(),
      ),
    );

    locator.registerFactory<SignUpController>(
      () => SignUpController(
        locator<AuthService>(),
      ),
    );

    locator.registerFactory<SplashController>(
      () => SplashController(),
    );

    locator.registerLazySingleton<HomePageController>(
      () => HomePageController(),
    );

    locator.registerLazySingleton<BalanceCardController>(
      () => BalanceCardController(),
    );

    locator.registerLazySingleton<AccountController>(
      () => AccountController(),
    );

    locator.registerLazySingleton<OfxPageController>(
      () => OfxPageController(),
    );

    locator.registerLazySingleton<StatisticsController>(
      () => StatisticsController(),
    );

    locator.registerLazySingleton<StatisticCardController>(
      () => StatisticCardController(),
    );

    locator.registerLazySingleton<CategoriesController>(
      () => CategoriesController(),
    );

    locator.registerLazySingleton<UserNameNotifier>(
      () => UserNameNotifier(),
    );

    locator.registerLazySingleton<AppLocale>(
      () => AppLocale(),
    );
  } catch (err) {
    log('Error: $err');
  }
}

void disposeDependencies() {
  // locator<AppLocale>().dispose();
  locator<UserNameNotifier>().dispose();
  locator<CategoriesController>().dispose();
  locator<StatisticCardController>().dispose();
  locator<StatisticsController>().dispose();
  locator<TransactionController>().dispose();
  locator<AccountController>().dispose();
  locator<BalanceCardController>().dispose();
  locator<HomePageController>().dispose();
  locator<SplashController>().dispose();
  locator<SignUpController>().dispose();
  locator<SignInController>().dispose();
  // locator<TransDayRepository>().dispose();
  // locator<BalanceRepository>().dispose();
  // locator<TransferRepository>().dispose();
  // locator<TransactionRepository>().dispose();
  // locator<CategoryRepository>().dispose();
  // locator<AccountRepository>().dispose();
  // locator<IconRepository>().dispose();
  // locator<UserRepository>().dispose();
  // locator<AppScale>().dispose();
  // locator<MoneyMaskedText>().dispose();
  // locator<CategoriesIcons>().dispose();
  // locator<CurrentLanguage>().dispose();
  // locator<CurrentTheme>().dispose();
  // locator<CurrentBalance>().dispose();
  // locator<CurrentAccount>().dispose();
  // locator<CurrentUser>().dispose();
  // locator<DatabaseHelper>().dispose();
  // locator<AuthService>().dispose();
  locator<AbstractDatabaseRepository>().dispose();
}
