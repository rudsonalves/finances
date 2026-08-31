import 'package:finances/common/models/extends_date.dart';
import 'package:finances/common/models/transaction_db_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () {
      final TransactionDbModel source = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 30,
        transDescription: 'Compra no mercado',
        transCategoryId: 40,
        transValue: -123.45,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 50,
        transDate: ExtendedDate(2026, 8, 31, 10, 20, 30, 456),
        transOfxId: 60,
      );

      final TransactionDbModel result =
          TransactionDbModel.fromMap(source.toMap());

      expect(result.transId, source.transId);
      expect(result.transBalanceId, source.transBalanceId);
      expect(result.transAccountId, source.transAccountId);
      expect(result.transDescription, source.transDescription);
      expect(result.transCategoryId, source.transCategoryId);
      expect(result.transValue, source.transValue);
      expect(result.transStatus, source.transStatus);
      expect(result.transTransferId, source.transTransferId);
      expect(result.transDate, source.transDate);
      expect(result.transOfxId, source.transOfxId);
    });

    test('preserva campos opcionais nulos', () {
      final TransactionDbModel source = TransactionDbModel(
        transAccountId: 1,
        transDescription: 'Receita',
        transCategoryId: 2,
        transValue: 100,
        transDate: ExtendedDate(2026, 8, 31),
      );

      final TransactionDbModel result =
          TransactionDbModel.fromMap(source.toMap());

      expect(result.transId, isNull);
      expect(result.transBalanceId, isNull);
      expect(result.transTransferId, isNull);
      expect(result.transOfxId, isNull);
    });

    test('aceita valor monetário representado como inteiro', () {
      final Map<String, dynamic> map = {
        'transId': 1,
        'transBalanceId': null,
        'transAccountId': 2,
        'transDescription': 'Valor inteiro',
        'transCategoryId': 3,
        'transValue': 100,
        'transStatus': TransStatus.transactionChecked.index,
        'transTransferId': null,
        'transDate': ExtendedDate(2026, 8, 31).millisecondsSinceEpoch,
        'transOfxId': null,
      };

      final TransactionDbModel result = TransactionDbModel.fromMap(map);

      expect(result.transValue, 100.0);
    });

    test('reconstrói o modelo produzido por toJson', () {
      final TransactionDbModel source = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 30,
        transDescription: 'Compra no mercado',
        transCategoryId: 40,
        transValue: -123.45,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 50,
        transDate: ExtendedDate(2026, 8, 31, 10, 20),
        transOfxId: 60,
      );

      final TransactionDbModel result =
          TransactionDbModel.fromJson(source.toJson());

      expect(result.transId, source.transId);
      expect(result.transBalanceId, source.transBalanceId);
      expect(result.transAccountId, source.transAccountId);
      expect(result.transDescription, source.transDescription);
      expect(result.transCategoryId, source.transCategoryId);
      expect(result.transValue, source.transValue);
      expect(result.transStatus, source.transStatus);
      expect(result.transTransferId, source.transTransferId);
      expect(result.transDate, source.transDate);
      expect(result.transOfxId, source.transOfxId);
    });
  });

  group('TransactionDbModel.copy', () {
    test('cria uma nova transação preservando os dados financeiros', () {
      final TransactionDbModel source = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 30,
        transDescription: 'Parcela',
        transCategoryId: 40,
        transValue: -123.45,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 50,
        transDate: ExtendedDate(2026, 8, 31, 10, 20),
        transOfxId: 60,
      );

      final TransactionDbModel result = source.copy();

      expect(result, isNot(same(source)));
      expect(result.transId, isNull);
      expect(result.transBalanceId, source.transBalanceId);
      expect(result.transAccountId, source.transAccountId);
      expect(result.transDescription, source.transDescription);
      expect(result.transCategoryId, source.transCategoryId);
      expect(result.transValue, source.transValue);
      expect(result.transStatus, source.transStatus);
      expect(result.transTransferId, source.transTransferId);
      expect(result.transDate, source.transDate);
      expect(result.transOfxId, source.transOfxId);
    });
  });

  group('TransactionDbModel.copyToTransfer', () {
    test('cria a contraparte da transferência na conta de destino', () {
      final TransactionDbModel source = TransactionDbModel(
        transId: 10,
        transBalanceId: 20,
        transAccountId: 30,
        transDescription: 'Transferência',
        transCategoryId: 40,
        transValue: -123.45,
        transStatus: TransStatus.transactionChecked,
        transTransferId: 50,
        transDate: ExtendedDate(2026, 8, 31, 10, 20),
        transOfxId: 60,
      );

      final TransactionDbModel result = source.copyToTransfer(31);

      expect(result, isNot(same(source)));
      expect(result.transId, isNull);
      expect(result.transAccountId, 31);
      expect(result.transValue, 123.45);
      expect(result.transBalanceId, source.transBalanceId);
      expect(result.transDescription, source.transDescription);
      expect(result.transCategoryId, source.transCategoryId);
      expect(result.transStatus, source.transStatus);
      expect(result.transTransferId, source.transTransferId);
      expect(result.transDate, source.transDate);
      expect(result.transOfxId, source.transOfxId);
    });

    test('inverte também o valor de uma transferência positiva', () {
      final TransactionDbModel source = TransactionDbModel(
        transAccountId: 1,
        transDescription: 'Transferência',
        transCategoryId: 2,
        transValue: 100,
        transDate: ExtendedDate(2026, 8, 31),
      );

      final TransactionDbModel result = source.copyToTransfer(2);

      expect(result.transValue, -100);
    });
  });
}
