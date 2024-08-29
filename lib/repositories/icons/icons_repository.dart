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

import '../../store/stores/icon_store.dart';
import 'abstract_icons_repository.dart';
import '../../common/models/icons_model.dart';

class IconsRepository extends AbstractIconRepository {
  final _store = IconStore();

  @override
  Future<int> addIcon(IconModel iconModel) async {
    int result = await _store.insertIcon(iconModel.toMap());
    if (result < 0) {
      throw Exception('addIcon return id $result');
    }
    return result;
  }

  @override
  Future<IconModel> getIconId(int id) async {
    final iconMap = await _store.queryIconId(id);
    if (iconMap == null || iconMap.isEmpty) {
      throw Exception('Icon id $id does not exist');
    }
    return IconModel.fromMap(iconMap);
  }

  @override
  Future<void> updateIcon(IconModel iconModel) async {
    if (iconModel.iconId == null) {
      throw Exception('Icon ${iconModel.iconName} don\'t have id');
    }
    await _store.updateIcon(iconModel.toMap());
  }
}
