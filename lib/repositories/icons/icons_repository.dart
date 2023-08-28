import '../../common/models/icons_model.dart';

abstract class IconRepository {
  Future<IconModel> getIconId(int id);
  Future<int> addIcon(IconModel iconModel);
  Future<void> updateIcon(IconModel iconModel);
  // Future<void> deleteIcon(IconModel iconModel);
}
