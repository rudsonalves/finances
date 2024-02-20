import '../../store/icon_store.dart';
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
