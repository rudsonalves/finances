import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/admob/admob_google.dart';
import '../../common/admob/app_lifecycle_reactor.dart';
import '../../common/admob/app_open_ad_manager.dart';
import '../../common/models/transaction_db_model.dart';
import '../../common/models/user_name_notifier.dart';
import '../../locator.dart';
import '../../repositories/category/category_repository.dart';
import '../help_manager/main_manager.dart';
import './home_page_state.dart';
import './home_page_controller.dart';
import './balance_card/balance_card.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/transaction_dismissible_tile.dart';
import '../../common/extensions/app_scale.dart';
import '../../common/models/extends_date.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/app_top_border.dart';
import '../../common/current_models/current_user.dart';
import '../../common/constants/themes/app_text_styles.dart';
import '../../common/widgets/custom_circular_progress_indicator.dart';
import '../../features/home_page/balance_card/balance_card_controller.dart';
import 'widgets/home_popup_menu_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _controller = locator<HomePageController>();
  final _balanceController = locator<BalanceCardController>();
  final ScrollController _listViewController = ScrollController();
  final _userNameNotifier = locator<UserNameNotifier>();
  String _filterText = '';
  bool _fliterIsDescription = true;
  int _filterCategoryId = 0;

  ExtendedDate lastDate = ExtendedDate(1980, 1, 1);

  bool _showTutorial = true;

  @override
  void dispose() {
    // _controller.dispose();
    _balanceController.dispose();
    _listViewController.dispose();
    _userNameNotifier.dispose();
    disposeDependencies();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    _controller.init();
    _balanceController.getBalance();
    _userNameNotifier.init();

    if (adMobEnable) {
      AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
      _appLifecycleReactor =
          AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
      _appLifecycleReactor.listenToAppStateChanges();
    }
  }

  String greetingText() {
    int hour = DateTime.now().hour;
    final locale = AppLocalizations.of(context)!;

    if (hour < 12) return locale.greetingsGoodMorning;
    if (hour < 18) return locale.greetingsGoodAfternoon;
    return locale.greetingsGoodNight;
  }

  Future<void> loadMoreTransactions() async {
    final listViewPosition = _listViewController.position.pixels;
    await _controller.getNextTransactions();
    _listViewController.jumpTo(listViewPosition);
  }

  Widget noTransactions(AppLocalizations locale, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_trasactions.png',
            width: 100,
            height: 100,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 12),
          Text(
            locale.homePageNoTransactions,
            style: AppTextStyles.textStyleMedium14.copyWith(
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final currentUser = locator<CurrentUser>();
    final textScaleFactor = locator<AppScale>().textScaleFactor;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingText(),
              style: AppTextStyles.textStyle14.copyWith(
                color: onPrimary,
              ),
            ),
            AnimatedBuilder(
                animation: _userNameNotifier,
                builder: (context, _) {
                  return Text(
                    currentUser.userName ?? '',
                    style: AppTextStyles.textStyleSemiBold20.copyWith(
                      color: onPrimary,
                    ),
                  );
                }),
          ],
        ),
        actions: [
          SizedBox(
            width: 32,
            height: 32,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => managerTutorial(
                context,
                transactionsHelp,
              ),
              child: const Icon(
                Icons.question_mark,
                size: 20,
              ),
            ),
          ),
          const HomePagePopupMenuButtons(),
        ],
      ),
      body: Stack(
        children: [
          const AppTopBorder(),
          BalanceCard(
            textScale: textScaleFactor,
            controller: _balanceController,
            balanceCallBack: (account) {
              _controller.changeCurrentAccount(account);
            },
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale.homePageTransHistory,
                          style: AppTextStyles.textStyleSemiBold18.copyWith(
                            color: primary,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          customBorder: const CircleBorder(),
                          onLongPress: () {
                            _filterText = '';
                            _fliterIsDescription = true;
                            setState(() {});
                          },
                          onTap: () async {
                            String? text;
                            bool? isDescription;
                            try {
                              (text, isDescription) = await showDialog(
                                context: context,
                                builder: (context) => const FilterDialog(),
                              );
                              _filterText = text ?? '';
                              _fliterIsDescription = isDescription ?? true;

                              if (!_fliterIsDescription) {
                                _filterCategoryId = locator
                                    .get<CategoryRepository>()
                                    .getIdByName(_filterText);
                              }
                            } catch (err) {
                              _filterText = '';
                              _fliterIsDescription = true;
                            }

                            setState(() {});
                          },
                          child: Ink(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            width: 32,
                            height: 32,
                            child: Icon(
                              _filterText.isEmpty
                                  ? Icons.filter_alt_outlined
                                  : Icons.filter_alt,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        // State Loading...
                        if (_controller.state is HomePageStateLoading) {
                          return CustomCircularProgressIndicator(
                            color: primary,
                          );
                        }

                        // State Success...
                        if (_controller.state is HomePageStateSuccess) {
                          // isEmpty...
                          if (_controller.transactions.isEmpty) {
                            if (_showTutorial) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) =>
                                    managerTutorial(context, introductionHelp),
                              );
                              _showTutorial = false;
                            }
                            return noTransactions(locale, primary);
                          }

                          List<TransactionDbModel> transactions = [];

                          if (_filterText.isNotEmpty) {
                            for (final trans in _controller.transactions) {
                              if (_fliterIsDescription) {
                                if (trans.transDescription
                                    .toLowerCase()
                                    .contains(_filterText.toLowerCase())) {
                                  transactions.add(trans);
                                }
                              } else {
                                if (trans.transCategoryId ==
                                    _filterCategoryId) {
                                  transactions.add(trans);
                                }
                              }
                            }
                          } else {
                            transactions = _controller.transactions;
                          }
                          // building...
                          return ListView.builder(
                            controller: _listViewController,
                            itemCount: transactions.length + 1,
                            itemBuilder: (context, index) {
                              if (index != transactions.length) {
                                final transaction = transactions[index];

                                if (lastDate < transaction.transDate) {
                                  lastDate =
                                      transaction.transDate.lastDayOfTheMonth;
                                  _balanceController.setBalanceDate(lastDate);
                                }

                                return TransactionDismissibleTile(
                                  textScale: textScaleFactor,
                                  transaction: transactions[index],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    top: 4,
                                    bottom: 8,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _controller.lastDate != null
                                        ? loadMoreTransactions
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                    ),
                                    child: Text(locale.homePageSeeMore),
                                  ),
                                );
                              }
                            },
                          );
                        }

                        // State Error...
                        return noTransactions(locale, primary);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
