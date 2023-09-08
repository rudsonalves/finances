import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../common/current_models/current_user.dart';
import '../../../locator.dart';
import '../models/statistic_result.dart';
import '../statistic_controller.dart';
import 'statistic_cart.state.dart';

class StatisticCardController extends ChangeNotifier {
  final currentUser = locator.get<CurrentUser>();
  final statisticController = locator.get<StatisticsController>();
  final List<PlotData> _graphicData = [];

  List<PlotData> get graphicData => _graphicData;

  StatisticCardState _state = StatisticCardStateInitial();

  StatisticCardState get state => _state;

  void init() {
    getGraphicDataPoints();
  }

  void _changeState(StatisticCardState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> getGraphicDataPoints() async {
    _changeState(StatisticCardStateLoading());

    try {
      await statisticController.waitUntilSuccess();
      if (currentUser.userCategoryList.isEmpty) {
        _getIncomesExpensesData();
      } else {
        _getCategoriesData();
      }
      await Future.delayed(const Duration(milliseconds: 50));
      _changeState(StatisticCardStateSuccess());
    } catch (err) {
      _changeState(StatisticCardStateError());
      log('Error in getGraphicDataPoints(): $err');
    }
  }

  Future<void> addInCategoryList(String categoryName) async {
    if (currentUser.userCategoryList.contains(categoryName)) return;

    currentUser.userCategoryList.add(categoryName);
    await getGraphicDataPoints();
  }

  Future<void> removeInCategoryList(String categoryName) async {
    if (!currentUser.userCategoryList.contains(categoryName)) return;

    currentUser.userCategoryList.remove(categoryName);
    await getGraphicDataPoints();
  }

  void _getIncomesExpensesData() {
    final incomes =
        statisticController.incomes.values.toList().reversed.toList();
    final expanses =
        statisticController.expanses.values.toList().reversed.toList();

    _graphicData.clear();

    _graphicData.add(
      PlotData(
        data: incomes,
        name: 'Incomes',
      ),
    );

    _graphicData.add(
      PlotData(
        data: expanses.map((e) => e.abs()).toList(),
        name: 'Expenses',
      ),
    );
  }

  void _getCategoriesData() {
    _graphicData.clear();

    for (final categoryName in currentUser.userCategoryList) {
      final statisticsMap = statisticController.statisticsMap;
      final data = <double>[];

      for (final date in statisticsMap.keys) {
        final result = statisticsMap[date]!.firstWhere(
            (result) => result.categoryName == categoryName,
            orElse: () => StatisticResult());

        data.add(result.monthSum);
      }

      _graphicData.add(
        PlotData(
          name: categoryName,
          data: data.reversed.map((e) => e.abs()).toList(),
        ),
      );
    }
  }
}

class PlotData {
  String name;
  List<double> data;

  PlotData({
    required this.name,
    required this.data,
  });
}
