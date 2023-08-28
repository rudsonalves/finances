import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/models/extends_date.dart';
import '../../locator.dart';
import '../../services/database/database_helper.dart';
import 'statistic_state.dart';

class StatisticsController extends ChangeNotifier {
  final helper = locator.get<DatabaseHelper>();

  final Map<String, List<StatisticResult>> _statisticsList = {};

  final Map<String, double> _incomes = {};
  final Map<String, double> _expanses = {};

  Map<String, double> get incomes => _incomes;
  Map<String, double> get expanses => _expanses;

  Map<String, List<StatisticResult>> get statisticsList => _statisticsList;

  List<String> _strDates = [];

  int _index = 0;

  String get strDate => _strDates[_index];

  bool _redraw = false;

  bool get redraw {
    if (_redraw) {
      _redraw = false;
      log('redraw was true');
      return true;
    }
    log('redraw is false');
    return false;
  }

  void requestRedraw() {
    _redraw = true;
    log('redraw was made true');
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
    await getStatistics();
  }

  Future<void> getStatistics([ExtendedDate? date2]) async {
    final formatedDate = DateFormat.yMMMM();

    _changeState(StatisticsStateLoading());
    try {
      _statisticsList.clear();
      _incomes.clear();
      _expanses.clear();
      _strDates.clear();

      ExtendedDate date = ExtendedDate.now();
      int startDate;
      int endDate;

      int count = 0;
      while (count < 12) {
        (startDate, endDate) =
            ExtendedDate.getMillisecondsIntervalOfMonth(date);

        final statisticsMap = await helper.getTransactionSumsByCategory(
          startDate: startDate,
          endDate: endDate,
        );
        final String strDate = formatedDate.format(date);
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
        }
        _incomes[strDate] = incomes;
        _expanses[strDate] = expanses;

        count++;
        date = date.previousMonth();
      }
      _strDates = _strDates.reversed.toList();
      _index = _strDates.length - 1;
      _changeState(StatisticsStateSuccess());
    } catch (err) {
      _changeState(StatisticsStateError());
    }
  }
}

class StatisticResult {
  String categoryName;
  double totalSum;

  StatisticResult({
    required this.categoryName,
    required this.totalSum,
  });

  @override
  String toString() =>
      'StatisticResult(categoryName: $categoryName, totalSum: $totalSum)';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'totalSum': totalSum,
    };
  }

  factory StatisticResult.fromMap(Map<String, dynamic> map) {
    return StatisticResult(
      categoryName: map['categoryName'] as String,
      totalSum: map['totalSum'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory StatisticResult.fromJson(String source) =>
      StatisticResult.fromMap(json.decode(source) as Map<String, dynamic>);
}
