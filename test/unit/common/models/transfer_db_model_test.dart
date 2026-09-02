import 'package:finances/common/models/transfer_db_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransferDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () {
      final TransferDbModel source = TransferDbModel(
        transferId: 10,
        transferTransId0: 20,
        transferTransId1: 21,
        transferAccount0: 30,
        transferAccount1: 31,
      );

      final TransferDbModel result = TransferDbModel.fromMap(source.toMap());

      expect(result.transferId, source.transferId);
      expect(result.transferTransId0, source.transferTransId0);
      expect(result.transferTransId1, source.transferTransId1);
      expect(result.transferAccount0, source.transferAccount0);
      expect(result.transferAccount1, source.transferAccount1);
    });

    test('reconstrói um registro ainda não associado às transações', () {
      final TransferDbModel source = TransferDbModel();

      final TransferDbModel result = TransferDbModel.fromMap(source.toMap());

      expect(result.transferId, isNull);
      expect(result.transferTransId0, isNull);
      expect(result.transferTransId1, isNull);
      expect(result.transferAccount0, isNull);
      expect(result.transferAccount1, isNull);
    });

    test('preserva somente o identificador quando as relações são nulas', () {
      final TransferDbModel source = TransferDbModel(
        transferId: 10,
      );

      final TransferDbModel result = TransferDbModel.fromMap(source.toMap());

      expect(result.transferId, 10);
      expect(result.transferTransId0, isNull);
      expect(result.transferTransId1, isNull);
      expect(result.transferAccount0, isNull);
      expect(result.transferAccount1, isNull);
    });

    test('reconstrói o modelo produzido por toJson', () {
      final TransferDbModel source = TransferDbModel(
        transferId: 10,
        transferTransId0: 20,
        transferTransId1: 21,
        transferAccount0: 30,
        transferAccount1: 31,
      );

      final TransferDbModel result = TransferDbModel.fromJson(source.toJson());

      expect(result.transferId, source.transferId);
      expect(result.transferTransId0, source.transferTransId0);
      expect(result.transferTransId1, source.transferTransId1);
      expect(result.transferAccount0, source.transferAccount0);
      expect(result.transferAccount1, source.transferAccount1);
    });
  });
}
