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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/models/user_name_notifier.dart';
import '../../locator.dart';
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
import 'widgets/update_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _controller = locator<HomePageController>();
  final _balanceController = locator<BalanceCardController>();
  final _listViewController = ScrollController();
  final _userNameNotifier = locator<UserNameNotifier>();

  ExtendedDate lastDate = ExtendedDate(1980, 1, 1);

  bool _showTutorial = true;

  @override
  void dispose() {
    _controller.dispose();
    _balanceController.dispose();
    _listViewController.dispose();
    _userNameNotifier.dispose();
    disposeDependencies();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.init();
    _balanceController.getBalance();
    _userNameNotifier.init();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateMessage(context);
    });
  }

  String greetingText() {
    int hour = DateTime.now().hour;
    final locale = AppLocalizations.of(context)!;

    if (hour < 12) {
      return locale.greetingsGoodMorning;
    } else if (hour < 18) {
      return locale.greetingsGoodAfternoon;
    } else {
      return locale.greetingsGoodNight;
    }
  }

  Future<void> loadMoreTransactions() async {
    final listViewPosition = _listViewController.position.pixels;
    await _controller.getTransactions(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listViewController.hasClients) {
        _listViewController.jumpTo(listViewPosition);
      }
    });
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

  // Open filter dialog and set _filterText and _filterIsDescription
  Future<void> openFilter() async {
    String? text;
    bool? isDescription;
    try {
      (text, isDescription) = await showDialog(
        context: context,
        builder: (context) => const FilterDialog(),
      );
      _controller.setFilterValues(
        text: text ?? '',
        isDescription: isDescription ?? true,
      );
    } catch (err) {
      _controller.setFilterValues(
        text: '',
        isDescription: true,
      );
    }
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
            // Page Header Name and Greeting
            AnimatedBuilder(
                animation: _userNameNotifier,
                builder: (context, _) {
                  final userName = currentUser.userName == null ||
                          currentUser.userName!.isEmpty
                      ? '***'
                      : currentUser.userName!;
                  return Text(
                    userName,
                    style: AppTextStyles.textStyleSemiBold20.copyWith(
                      color: onPrimary,
                    ),
                  );
                }),
          ],
        ),
        actions: [
          // Manager Tutorial call
          SizedBox(
            width: 32,
            height: 32,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => managerTutorial(
                context,
                HelpTopics.transactionsHelp,
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
          // Background Image
          const AppTopBorder(),
          // Balance Card
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
                  // Transaction History and Filter
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Transaction History title
                        Text(
                          locale.homePageTransHistory,
                          style: AppTextStyles.textStyleSemiBold18.copyWith(
                            color: primary,
                          ),
                        ),
                        const Spacer(),
                        // Filter Icon
                        InkWell(
                          customBorder: const CircleBorder(),
                          onLongPress: _controller.cleanFilterValues,
                          onTap: openFilter,
                          child: Ink(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            width: 32,
                            height: 32,
                            child: ValueListenableBuilder(
                              valueListenable: _controller.isFiltred$,
                              builder: (context, value, _) => Icon(
                                !value
                                    ? Icons.filter_alt_outlined
                                    : Icons.filter_alt,
                                color: primary,
                              ),
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
                                (_) => managerTutorial(
                                    context, HelpTopics.introductionHelp),
                              );
                              _showTutorial = false;
                            }
                            return noTransactions(locale, primary);
                          }
                          _showTutorial = false;

                          // if necessary, filter transactions
                          final transactions = _controller.filterTransactions();

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
                                    onPressed: _controller.haveMoreTransactions
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
