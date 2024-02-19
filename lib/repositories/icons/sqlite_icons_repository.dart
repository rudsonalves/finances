import '../../locator.dart';
import '../../store/database_helper.dart';
import './icons_repository.dart';
import '../../common/models/icons_model.dart';

class SqflileIconsRepository extends IconRepository {
  final helper = locator<DatabaseHelper>();

  @override
  Future<int> addIcon(IconModel iconModel) async {
    int result = await helper.insertIcon(iconModel.toMap());
    if (result < 0) {
      throw Exception('addIcon return id $result');
    }
    return result;
  }

  @override
  Future<IconModel> getIconId(int id) async {
    final iconMap = await helper.queryIconId(id);
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
    await helper.updateIcon(iconModel.toMap());
  }
}
