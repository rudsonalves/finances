import '../../common/models/trans_day_db_model.dart';

abstract class TransDayRepository {
  // Map<String, TransDayDbModel> get transDay;
  // Future<void> init();
  Future<void> addTransDay(TransDayDbModel transDay);
  Future<void> deleteTransDayId(int transId);
  Future<TransDayDbModel> getTransDayId(int transId);
  // Future<List<TransDayDbModel>> getAllBalances();
}
