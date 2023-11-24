import 'dart:async';
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
  final helper = locator<DatabaseHelper>();
  Future<void>? _currentOperation;
  Completer<void>? _successCompleter;

  // bool _starting = true;

  // List of date x StatisticResult
  final Map<String, List<StatisticResult>> _statisticsList = {};
  // Lists of date x double
  final Map<String, double> _incomes = {};
  final Map<String, double> _expanses = {};

  // Lists of categoryName x StatisticTotal
  final Map<String, StatisticTotal> _totalByCategory = {};

  final currentUser = locator<CurrentUser>();

  late StatisticMedium _statReferenceType;

  bool _noData = true;

  bool get noData => _noData;

  StatisticMedium get statReference => _statReferenceType;

  List<String> _strDates = [];

  int _index = 0;

  String get strDate => _strDates[_index];
  List<String> get strDates => _strDates;
  Map<String, double> get incomes => _incomes;
  Map<String, double> get expanses => _expanses;
  Map<String, List<StatisticResult>> get statisticsMap => _statisticsList;

  StatisticsState _state = StatisticsStateInitial();

  StatisticsState get state => _state;

  bool _isStart = true;

  void _changeState(StatisticsState newState) {
    _state = newState;
    notifyListeners();
  }

  bool _recalculate = true;

  bool get recalculateRequested => _recalculate;

  void recalculate() {
    _recalculate = true;
  }

  Future<void> makeRecalculated() async {
    if (_recalculate != false && _isStart != true) {
      await getStatistics();
    }
  }

  Future<void> init() async {
    if (_isStart) {
      _statReferenceType = currentUser.userBudgetRef;
      await getStatistics();
      _isStart = false;
    }
  }

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
        final categoriesMap = locator<CategoryRepository>().categoriesMap;

        for (String categoryName in categoriesMap.keys) {
          referencesByCategory[categoryName] =
              categoriesMap[categoryName]!.categoryBudget;
        }
        break;
      case StatisticMedium.none:
        final categoriesMap = locator<CategoryRepository>().categoriesMap;

        for (String categoryName in categoriesMap.keys) {
          referencesByCategory[categoryName] = 0.0;
        }
        break;
    }
    return referencesByCategory;
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

  Future<void> getStatistics([bool doState = true]) async {
    if (_currentOperation != null) {
      await _currentOperation;
    }

    final completer = Completer<void>();
    _successCompleter = completer;
    _currentOperation = completer.future;

    if (doState) _changeState(StatisticsStateLoading());
    try {
      if (recalculateRequested) {
        _recalculate = false;
        // log('StatisticsController: Calculate...');
        await _calculateStatistics();
      }

      if (doState) _changeState(StatisticsStateSuccess());
      completer.complete();
    } catch (err) {
      if (doState) _changeState(StatisticsStateError());
      completer.completeError(err);
    } finally {
      _currentOperation = null;
    }
  }

  Future<void> _calculateStatistics() async {
    final formatedDate = DateFormat.yMMMM();
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
        if (result.monthSum > 0) {
          incomes += result.monthSum;
        } else {
          expanses += result.monthSum;
        }
        if (_totalByCategory.containsKey(result.categoryName)) {
          _totalByCategory[result.categoryName]!.addValue(result.monthSum);
        } else {
          _totalByCategory[result.categoryName] =
              StatisticTotal.create(result.monthSum);
        }
      }
      _incomes[strDate] = incomes;
      _expanses[strDate] = expanses;

      count++;
      dateIndex = dateIndex.previousMonth();
    }
    if (_totalByCategory.isNotEmpty) {
      _noData = false;
      _buildStatistics();
    } else {
      _noData = true;
    }
    _strDates = _strDates.reversed.toList();
    _index = _strDates.length - 1;
  }

  void _buildStatistics() {
    _setReferenceByCategory();
    for (final month in _statisticsList.keys) {
      final List<StatisticResult>? statInMonth = _statisticsList[month];
      if (statInMonth == null || statInMonth.isEmpty) {
        continue;
      }
      for (int index = 0; index < statInMonth.length; index++) {
        final category = statInMonth[index].categoryName;
        final reference = _totalByCategory[category]!.reference;
        final variation = reference != 0
            ? 100 * (statInMonth[index].monthSum - reference) / reference
            : null;

        statInMonth[index].variation = variation;
      }
    }
  }

  Future<void> setStatisticsReference(StatisticMedium statReferenceType) async {
    if (_statReferenceType == statReferenceType) return;

    if (_currentOperation != null) {
      await _currentOperation;
    }

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
    } finally {
      _currentOperation = null;
    }
  }

  Future<void> waitUntilSuccess() async {
    _successCompleter ??= Completer<void>();
    return await _successCompleter!.future;
  }
}
