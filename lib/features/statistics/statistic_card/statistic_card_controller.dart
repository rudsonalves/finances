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

import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../common/current_models/current_user.dart';
import '../../../locator.dart';
import '../../../repositories/category/abstract_category_repository.dart';
import '../models/statistic_result.dart';
import '../statistic_controller.dart';
import 'statistic_cart.state.dart';

class StatisticCardController extends ChangeNotifier {
  final currentUser = locator<CurrentUser>();
  final statisticController = locator<StatisticsController>();
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
      _changeState(StatisticCardStateSuccess());
    } catch (err) {
      _changeState(StatisticCardStateError());
      log('Error in getGraphicDataPoints(): $err');
    }
  }

  Future<void> addToCategoryList(String categoryName) async {
    if (currentUser.userCategoryList.contains(categoryName)) return;

    currentUser.userCategoryList.add(categoryName);
    await getGraphicDataPoints();
  }

  Future<void> removeFromCategoryList(String categoryName) async {
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
        data: expanses.map((element) => element.abs()).toList(),
        name: 'Expenses',
      ),
    );
  }

  void _getCategoriesData() {
    _graphicData.clear();
    final categoriesMap = locator<AbstractCategoryRepository>().categoriesMap;

    for (final categoryName in currentUser.userCategoryList) {
      final statisticsMap = statisticController.statisticsMap;
      final data = <double>[];

      for (final date in statisticsMap.keys) {
        final result = statisticsMap[date]!.firstWhere(
            (result) => result.categoryName == categoryName,
            orElse: () => StatisticResult());

        data.add(result.monthSum);
      }

      final signal = categoriesMap[categoryName]!.categoryIsIncome ? 1 : -1;

      _graphicData.add(
        PlotData(
          name: categoryName,
          data: data.reversed.map((element) => signal * element).toList(),
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
