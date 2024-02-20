import '../../store/transday_store.dart';
import 'abstract_trans_day_repository.dart';
import '../../common/models/trans_day_db_model.dart';

class TransDayRepository implements AbstractTransDayRepository {
  final _store = TransDayStore();

  @override
  Future<void> addTransDay(TransDayDbModel transDay) async {
    int result = await _store.insertTransDay(transDay.toMap());
    if (result < 0) {
      throw Exception('addTransDay return id $result');
    }
  }

  @override
  Future<void> deleteTransDayId(int transId) async {
    await _store.deleteTransDay(
      transId,
    );
  }

  @override
  Future<TransDayDbModel> getTransDayId(int transId) async {
    Map<String, Object?>? map = await _store.queryTransDayId(transId);
    if (map == null) {
      throw Exception('getTransDayAtTransId return null');
    }
    return TransDayDbModel.fromMap(map);
  }
}
