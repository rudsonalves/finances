import '../../locator.dart';
import './trans_day_repository.dart';
import '../../store/database_helper.dart';
import '../../common/models/trans_day_db_model.dart';

class SqfliteTransDayRepository implements TransDayRepository {
  final DatabaseHelper helper = locator<DatabaseHelper>();

  @override
  Future<void> addTransDay(TransDayDbModel transDay) async {
    int result = await helper.insertTransDay(transDay.toMap());
    if (result < 0) {
      throw Exception('addTransDay return id $result');
    }
  }

  @override
  Future<void> deleteTransDayId(int transId) async {
    await helper.deleteTransDay(
      transId,
    );
  }

  @override
  Future<TransDayDbModel> getTransDayId(int transId) async {
    Map<String, Object?>? map = await helper.queryTransDayId(transId);
    if (map == null) {
      throw Exception('getTransDayAtTransId return null');
    }
    return TransDayDbModel.fromMap(map);
  }
}
