import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/constants/app_constants.dart';
import '../../common/current_models/current_user.dart';
import '../../common/models/extends_date.dart';
import '../../locator.dart';
import '../../repositories/category/category_repository.dart';
import '../../services/database/database_helper.dart';
import 'models/statistic_result.dart';
import 'models/statistic_total.dart';
import 'statistic_state.dart';

class StatisticsController extends ChangeNotifier {
  final helper = locator.get<DatabaseHelper>();

  // List of date x StatisticResult
  final Map<String, List<StatisticResult>> _statisticsList = {};
  // Lists of date x double
  final Map<String, double> _incomes = {};
  final Map<String, double> _expanses = {};

  // Lists of categoryName x StatisticTotal
  final Map<String, StatisticTotal> _totalByCategory = {};

  final currentUser = locator.get<CurrentUser>();

  late StatisticMedium _statReferenceType;

  StatisticMedium get statReference => _statReferenceType;

  List<String> _strDates = [];

  int _index = 0;

  String get strDate => _strDates[_index];
  List<String> get strDates => _strDates;
  Map<String, double> get incomes => _incomes;
  Map<String, double> get expanses => _expanses;
  Map<String, List<StatisticResult>> get statisticsList => _statisticsList;

  void _setReferenceByCategory() {
    final Map<String, double> referencesByCategory =
        getReferences(_statReferenceType);

    for (String categoryName in _totalByCategory.keys) {
      _totalByCategory[categoryName]!.reference =
          referencesByCategory[categoryName] ?? 0.0;
    }
  }

  Map<String, double> getReferences(StatisticMedium statReference) {
    final Map<String, double> referencesByCategory = {};

    switch (statReference) {
      case StatisticMedium.mediumMonth:
        for (String categoryName in _totalByCategory.keys) {
          referencesByCategory[categoryName] =
              _totalByCategory[categoryName]!.total /
                  _totalByCategory[categoryName]!.count;
        }
        break;
      case StatisticMedium.medium12:
        for (String categoryName in _totalByCategory.keys) {
          referencesByCategory[categoryName] =
              _totalByCategory[categoryName]!.total / 12;
        }
        break;
      case StatisticMedium.categoryBudget:
        final categoriesMap = locator.get<CategoryRepository>().categoriesMap;

        for (String categoryName in categoriesMap.keys) {
          referencesByCategory[categoryName] =
              categoriesMap[categoryName]!.categoryBudget;
        }
        break;
      case StatisticMedium.none:
        final categoriesMap = locator.get<CategoryRepository>().categoriesMap;

        for (String categoryName in categoriesMap.keys) {
          referencesByCategory[categoryName] = 0.0;
        }
        break;
    }
    return referencesByCategory;
  }

  bool _redraw = false;

  bool get redraw {
    if (_redraw) {
      _redraw = false;
      return true;
    }
    return false;
  }

  void requestRedraw() {
    _redraw = true;
  }

  Future<void> nextMonth() async {
    _changeState(StatisticsStateLoading());
    if (_index < _strDates.length - 1) {
      _index++;
    }
    _changeState(StatisticsStateSuccess());
  }

  Future<void> previusMonth() async {
    _changeState(StatisticsStateLoading());
    if (_index > 0) {
      _index--;
    }
    _changeState(StatisticsStateSuccess());
  }

  StatisticsState _state = StatisticsStateInitial();

  StatisticsState get state => _state;

  void _changeState(StatisticsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    _statReferenceType = currentUser.userBudgetRef;
    await getStatistics();
  }

  Future<void> getStatistics() async {
    final formatedDate = DateFormat.yMMMM();

    _changeState(StatisticsStateLoading());
    try {
      _statisticsList.clear();
      _incomes.clear();
      _expanses.clear();
      _strDates.clear();
      _totalByCategory.clear();

      ExtendedDate dateIndex = ExtendedDate.now();
      int startDate;
      int endDate;

      int count = 0;
      while (count < 12) {
        (startDate, endDate) =
            ExtendedDate.getMillisecondsIntervalOfMonth(dateIndex);

        final statisticsMap = await helper.getTransactionSumsByCategory(
          startDate: startDate,
          endDate: endDate,
        );
        final String strDate = formatedDate.format(dateIndex);
        double incomes = 0.0;
        double expanses = 0.0;
        _statisticsList[strDate] = [];
        _strDates.add(strDate);

        if (statisticsMap == null) throw Exception('No statistics found!');

        for (final map in statisticsMap) {
          final result = StatisticResult.fromMap(map);
          _statisticsList[strDate]!.add(result);
          if (result.totalSum > 0) {
            incomes += result.totalSum;
          } else {
            expanses += result.totalSum;
          }
          if (_totalByCategory.containsKey(result.categoryName)) {
            _totalByCategory[result.categoryName]!.addValue(result.totalSum);
          } else {
            _totalByCategory[result.categoryName] =
                StatisticTotal.create(result.totalSum);
          }
        }
        _incomes[strDate] = incomes;
        _expanses[strDate] = expanses;

        count++;
        dateIndex = dateIndex.previousMonth();
      }
      _buildStatistics();
      _strDates = _strDates.reversed.toList();
      _index = _strDates.length - 1;
      _changeState(StatisticsStateSuccess());
    } catch (err) {
      _changeState(StatisticsStateError());
    }
  }

  void _buildStatistics() {
    _setReferenceByCategory();
    for (final month in _statisticsList.keys) {
      // log('$month:');
      final List<StatisticResult>? statInMonth = _statisticsList[month];
      if (statInMonth == null || statInMonth.isEmpty) {
        continue;
      }
      for (int index = 0; index < statInMonth.length; index++) {
        final category = statInMonth[index].categoryName;
        final reference = _totalByCategory[category]!.reference;
        final variation = reference != 0
            ? 100 * (statInMonth[index].totalSum - reference) / reference
            : null;

        statInMonth[index].variation = variation;

        // log('Category: $category/${reference.toStringAsFixed(2)}'
        //     '/${variation != null ? variation.toStringAsFixed(0) : 'NaN'}');
      }
    }
  }

  Future<void> setStatisticsReference(StatisticMedium statReferenceType) async {
    if (_statReferenceType == statReferenceType) return;

    try {
      _changeState(StatisticsStateLoading());
      _statReferenceType = statReferenceType;
      currentUser.userBudgetRef = statReferenceType;
      await currentUser.updateUserBudgetRef();
      _buildStatistics();
      _changeState(StatisticsStateSuccess());
    } catch (err) {
      log('Error: $err');
      _changeState(StatisticsStateError());
    }
  }
}
