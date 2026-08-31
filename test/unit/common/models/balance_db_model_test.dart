import 'package:finances/common/models/balance_db_model.dart';
import 'package:finances/common/models/extends_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalanceDbModel serialização', () {
    test('reconstrói todos os campos produzidos por toMap', () {
      final BalanceDbModel source = BalanceDbModel(
        balanceId: 10,
        balanceAccountId: 20,
        balanceDate: ExtendedDate(2026, 8, 31),
        balanceTransCount: 3,
        balanceOpen: 100.25,
        balanceClose: 250.75,
      );

      final BalanceDbModel result = BalanceDbModel.fromMap(source.toMap());

      expect(result.balanceId, source.balanceId);
      expect(result.balanceAccountId, source.balanceAccountId);
      expect(result.balanceDate, source.balanceDate);
      expect(result.balanceTransCount, source.balanceTransCount);
      expect(result.balanceOpen, source.balanceOpen);
      expect(result.balanceClose, source.balanceClose);
    });

    test('preserva identificador nulo em um novo saldo', () {
      final BalanceDbModel source = BalanceDbModel(
        balanceAccountId: 20,
        balanceDate: ExtendedDate(2026, 8, 31),
        balanceOpen: 100,
        balanceClose: 100,
      );

      final BalanceDbModel result = BalanceDbModel.fromMap(source.toMap());

      expect(result.balanceId, isNull);
      expect(result.balanceAccountId, 20);
      expect(result.balanceDate, ExtendedDate(2026, 8, 31));
    });

    test('aceita saldos representados como números inteiros', () {
      final Map<String, dynamic> map = {
        'balanceId': 10,
        'balanceAccountId': 20,
        'balanceDate': ExtendedDate(2026, 8, 31).millisecondsSinceEpoch,
        'balanceTransCount': 3,
        'balanceOpen': 100,
        'balanceClose': 250,
      };

      final BalanceDbModel result = BalanceDbModel.fromMap(map);

      expect(result.balanceOpen, 100.0);
      expect(result.balanceClose, 250.0);
    });

    test('reconstrói o modelo produzido por toJson', () {
      final BalanceDbModel source = BalanceDbModel(
        balanceId: 10,
        balanceAccountId: 20,
        balanceDate: ExtendedDate(2026, 8, 31),
        balanceTransCount: 3,
        balanceOpen: 100.25,
        balanceClose: 250.75,
      );

      final BalanceDbModel result = BalanceDbModel.fromJson(source.toJson());

      expect(result.balanceId, source.balanceId);
      expect(result.balanceAccountId, source.balanceAccountId);
      expect(result.balanceDate, source.balanceDate);
      expect(result.balanceTransCount, source.balanceTransCount);
      expect(result.balanceOpen, source.balanceOpen);
      expect(result.balanceClose, source.balanceClose);
    });
  });

  group('BalanceDbModel.toMap', () {
    test('rejeita saldo sem conta associada', () {
      final BalanceDbModel balance = BalanceDbModel(
        balanceDate: ExtendedDate(2026, 8, 31),
      );

      expect(
        balance.toMap,
        throwsA(isA<StateError>()),
      );
    });

    test('rejeita saldo sem data', () {
      final BalanceDbModel balance = BalanceDbModel(
        balanceAccountId: 1,
      );

      expect(
        balance.toMap,
        throwsA(isA<StateError>()),
      );
    });
  });
}
