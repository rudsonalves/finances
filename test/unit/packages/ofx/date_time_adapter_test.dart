import 'package:finances/packages/ofx/lib/src/adapter/date_time_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeAdapter.stringToDateTime', () {
    test('extrai os primeiros 14 dígitos como uma data UTC', () {
      final result = DateTimeAdapter.stringToDateTime(
        '20260901103000[-3:GMT]',
      );

      expect(result, DateTime.utc(2026, 9, 1, 10, 30));
      expect(result.isUtc, isTrue);
    });

    test('rejeita componentes de data inválidos', () {
      expect(
        () => DateTimeAdapter.stringToDateTime(
          '20261301103000[-3:GMT]',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('DateTimeAdapter.stringDateTimeInTimeZoneLocal', () {
    test('converte o instante informado para o fuso local', () {
      final result = DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        '20260901103000[-3:GMT]',
      );

      final expected = DateTime.utc(2026, 9, 1, 13, 30).toLocal();

      expect(result, expected);
      expect(result.isUtc, isFalse);
    });

    test('aceita deslocamento positivo com sinal explícito', () {
      final result = DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        '20260901003000[+2:GMT]',
      );

      final expected = DateTime.utc(2026, 8, 31, 22, 30).toLocal();

      expect(result, expected);
      expect(result.isUtc, isFalse);
    });

    test('aceita a identificação brasileira BRT', () {
      final result = DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        '20260901103000[-3:BRT]',
      );

      final expected = DateTime.utc(2026, 9, 1, 13, 30).toLocal();

      expect(result, expected);
      expect(result.isUtc, isFalse);
    });

    test('assume UTC quando o fuso não é informado', () {
      final result = DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        '20260901103000',
      );

      final expected = DateTime.utc(2026, 9, 1, 10, 30).toLocal();

      expect(result, expected);
      expect(result.isUtc, isFalse);
    });
  });
}
