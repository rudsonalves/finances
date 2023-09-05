import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../locator.dart';
import './home_page_state.dart';
import './home_page_controller.dart';
import './balance_card/balance_card.dart';
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
  final _controller = locator.get<HomePageController>();
  final _balanceController = locator.get<BalanceCardController>();
  final ScrollController _listViewController = ScrollController();

  ExtendedDate lastDate = ExtendedDate(1980, 1, 1);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.getTransactions();
    _balanceController.getBalance();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;
    final currentUser = locator.get<CurrentUser>();
    final textScaleFactor = locator.get<AppScale>().textScaleFactor;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingText(),
              style: AppTextStyles.textStyle14.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
            Text(
              currentUser.userName!,
              style: AppTextStyles.textStyleSemiBold20.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        actions: const [
          HomePagePopupMenuButtons(),
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
                            fontWeight: FontWeight.w700,
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
                            color: Theme.of(context).colorScheme.primary,
                          );
                        }

                        // State Success...
                        if (_controller.state is HomePageStateSuccess) {
                          // isEmpty...
                          if (_controller.transactions.isEmpty) {
                            return Center(
                              child: Text(
                                locale.homePageNoTransactions,
                              ),
                            );
                          }
                          // building...
                          return ListView.builder(
                            controller: _listViewController,
                            itemCount: _controller.transactions.length + 1,
                            itemBuilder: (context, index) {
                              if (index != _controller.transactions.length) {
                                final transaction =
                                    _controller.transactions[index];

                                if (lastDate < transaction.transDate) {
                                  lastDate =
                                      transaction.transDate.lastDayOfTheMonth;
                                  _balanceController.setBalanceDate(lastDate);
                                }

                                return TransactionDismissibleTile(
                                  textScale: textScaleFactor,
                                  transaction: _controller.transactions[index],
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
                        return Center(
                          child: Text(
                            locale.homePageError,
                          ),
                        );
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
