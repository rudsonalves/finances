import 'dart:developer';

import 'package:get_it/get_it.dart';

import './common/extensions/app_scale.dart';
import './common/models/categories_icons.dart';
import './services/database/sqflite_helper.dart';
import './repositories/user/user_repository.dart';
import './features/splash/splash_controller.dart';
import './services/database/database_helper.dart';
import './common/current_models/current_user.dart';
import './common/extensions/money_masked_text.dart';
import './features/sign_in/sign_in_controller.dart';
import './features/sign_up/sign_up_controller.dart';
import './common/current_models/current_theme.dart';
import 'common/current_models/current_account.dart';
import './services/authentication/auth_service.dart';
import './common/current_models/current_balance.dart';
import 'features/account/account_controller.dart';
import 'features/statistics/statistic_controller.dart';
import 'repositories/account/account_repository.dart';
import './features/category/category_controller.dart';
import './common/current_models/current_language.dart';
import './features/home_page/home_page_controller.dart';
import './repositories/balance/balance_repository.dart';
import './repositories/category/category_repository.dart';
import './repositories/user/sqflite_user_repository.dart';
import './repositories/trans_day/trans_day_repository.dart';
import './features/transaction/transaction_controller.dart';
import './services/authentication/firebase_auth_service.dart';
import 'repositories/account/sqflite_account_repository.dart';
import './repositories/balance/sqflite_balance_repository.dart';
import './repositories/transaction/transaction_repository.dart';
import './repositories/category/sqflile_category_repository.dart';
import './repositories/trans_day/sqflite_trans_day_repository.dart';
import './features/home_page/balance_card/balance_card_controller.dart';
import './repositories/transaction/sqflite_transaction_repository.dart';
import 'common/constants/themes/app_icons.dart';
import 'common/models/icons_model.dart';
import 'repositories/icons/icons_repository.dart';
import 'repositories/icons/sqlite_icons_repository.dart';
import 'repositories/transfer_repository/sqflite_transfer_repository.dart';
import 'repositories/transfer_repository/transfer_repository.dart';

final GetIt locator = GetIt.instance;

void setupDependencies() {
  try {
    locator.registerSingleton<AuthService>(
      FirebaseAuthService(),
    );

    locator.registerSingleton<DatabaseHelper>(
      SqfliteHelper(),
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

    locator.registerFactory<MoneyMaskedText>(
      () => getMoneyMaskedText(),
    );

    locator.registerLazySingleton<AppScale>(
      () => AppScale(),
    );

    locator.registerLazySingleton<UserRepository>(
      () => SqfliteUserRepository(),
    );

    locator.registerLazySingleton<IconRepository>(
      () => SqflileIconsRepository(),
    );

    locator.registerLazySingleton<AccountRepository>(
      () => SqfliteAccountRepository(),
    );

    locator.registerLazySingleton<CategoryRepository>(
      () => SqflileCategoryRepository(),
    );

    locator.registerLazySingleton<TransactionRepository>(
      () => SqfliteTransactionRepository(),
    );

    locator.registerLazySingleton<TransferRepository>(
      () => SqfliteTransferRepository(),
    );

    locator.registerLazySingleton<BalanceRepository>(
      () => SqfliteBalanceRepository(),
    );

    locator.registerLazySingleton<TransDayRepository>(
      () => SqfliteTransDayRepository(),
    );

    locator.registerFactory<SignInController>(
      () => SignInController(
        locator.get<AuthService>(),
      ),
    );

    locator.registerFactory<SignUpController>(
      () => SignUpController(
        locator.get<AuthService>(),
      ),
    );

    locator.registerFactory<SplashController>(
      () => SplashController(),
    );

    locator.registerLazySingleton<HomePageController>(
      () => HomePageController(),
    );

    locator.registerLazySingleton<CategoryController>(
      () => CategoryController(),
    );

    locator.registerLazySingleton<BalanceCardController>(
      () => BalanceCardController(),
    );

    locator.registerLazySingleton<AccountController>(
      () => AccountController(),
    );

    // TODO: change to registerFactory
    locator.registerLazySingleton<TransactionController>(
      () => TransactionController(),
    );

    locator.registerLazySingleton<StatisticsController>(
      () => StatisticsController(),
    );
  } catch (err) {
    log('Error: $err');
  }
}
