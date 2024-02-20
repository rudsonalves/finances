import '../../common/models/trans_day_db_model.dart';

abstract class AbstractTransDayRepository {
  Future<void> addTransDay(TransDayDbModel transDay);
  Future<void> deleteTransDayId(int transId);
  Future<TransDayDbModel> getTransDayId(int transId);
}
