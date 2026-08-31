import '../repositories/ofx_import/abstract_ofx_import_repository.dart';
import '../repositories/ofx_import/ofx_import_repository.dart';

sealed class OfxImportManager {
  OfxImportManager._();

  static AbstractOfxImportRepository _repository(
    AbstractOfxImportRepository? repository,
  ) {
    return repository ?? OfxImportRepository();
  }

  static Future<bool> isImported({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
    AbstractOfxImportRepository? repository,
  }) {
    return _repository(repository).isImported(
      institutionId: institutionId,
      bankAccountId: bankAccountId,
      fitId: fitId,
    );
  }

  static Future<bool> claim({
    required int ofxAccountId,
    required String institutionId,
    required String bankAccountId,
    required String fitId,
    AbstractOfxImportRepository? repository,
  }) {
    return _repository(repository).claim(
      ofxAccountId: ofxAccountId,
      institutionId: institutionId,
      bankAccountId: bankAccountId,
      fitId: fitId,
    );
  }

  static Future<void> release({
    required String institutionId,
    required String bankAccountId,
    required String fitId,
    AbstractOfxImportRepository? repository,
  }) {
    return _repository(repository).release(
      institutionId: institutionId,
      bankAccountId: bankAccountId,
      fitId: fitId,
    );
  }
}
