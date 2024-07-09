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

import '../../common/models/account_db_model.dart';
import '../../common/models/category_db_model.dart';
import '../../store/manage_counter.dart';
import 'abstract_counter_repository.dart';

class CounterRepository implements AbstractCounterRepository {
  @override
  Future<int> countTransactionForCategoryId(CategoryDbModel category) async {
    final id = category.categoryId;
    if (id == null) return 0;
    return await ManageCount.countTransactionForCategoryId(id);
  }

  @override
  Future<int> countTransactionsForAccountId(AccountDbModel account) async {
    final id = account.accountId;
    if (id == null) return 0;
    return await ManageCount.countTransactionsForAccountId(id);
  }
}
