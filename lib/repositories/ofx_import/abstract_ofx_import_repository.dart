abstract class AbstractOfxImportRepository {
  Future<bool> isImported({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  });

  Future<bool> claim({
    required int ofxAccountId,
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  });

  Future<void> release({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
  });
}
