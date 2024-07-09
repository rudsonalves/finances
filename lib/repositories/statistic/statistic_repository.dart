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

import '../../store/stores/statistic_store.dart';
import 'abstract_statistic_repository.dart';

class StatisticRepository implements AbstractStatisticRepository {
  final _store = StatisticStore();

  @override
  Future<List<Map<String, dynamic>>?> getTransactionSumsByCategory({
    required int startDate,
    required int endDate,
  }) async {
    return await _store.getTransactionSumsByCategory(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
