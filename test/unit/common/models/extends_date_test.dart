import 'package:finances/common/models/extends_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtendedDate.fromDateTime', () {
    test('preserva todos os componentes da data e hora', () {
      final DateTime source = DateTime(
        2026,
        8,
        31,
        10,
        20,
        30,
        456,
        789,
      );

      final ExtendedDate result = ExtendedDate.fromDateTime(source);

      expect(result.year, source.year);
      expect(result.month, source.month);
      expect(result.day, source.day);
      expect(result.hour, source.hour);
      expect(result.minute, source.minute);
      expect(result.second, source.second);
      expect(result.millisecond, source.millisecond);
      expect(result.microsecond, source.microsecond);
    });

    test('preserva um instante UTC', () {
      final DateTime source = DateTime.utc(
        2026,
        8,
        31,
        10,
        20,
        30,
      );

      final ExtendedDate result = ExtendedDate.fromDateTime(source);

      expect(result.isUtc, isTrue);
      expect(
        result.millisecondsSinceEpoch,
        source.millisecondsSinceEpoch,
      );
    });
  });

  group('ExtendedDate.parse', () {
    test('preserva milissegundos e microssegundos', () {
      final ExtendedDate result = ExtendedDate.parse(
        '2026-08-31T10:20:30.456789',
      );

      expect(result.year, 2026);
      expect(result.month, 8);
      expect(result.day, 31);
      expect(result.hour, 10);
      expect(result.minute, 20);
      expect(result.second, 30);
      expect(result.millisecond, 456);
      expect(result.microsecond, 789);
    });

    test('preserva o fuso UTC indicado pelo sufixo Z', () {
      final ExtendedDate result = ExtendedDate.parse(
        '2026-08-31T10:20:30.000Z',
      );

      expect(result.isUtc, isTrue);
      expect(
        result.millisecondsSinceEpoch,
        DateTime.utc(2026, 8, 31, 10, 20, 30).millisecondsSinceEpoch,
      );
    });
  });

  group('ExtendedDate.onlyDate', () {
    test('remove todos os componentes de horário', () {
      final ExtendedDate source = ExtendedDate(
        2026,
        8,
        31,
        10,
        20,
        30,
        456,
        789,
      );

      final ExtendedDate result = source.onlyDate;

      expect(result, ExtendedDate(2026, 8, 31));
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
      expect(result.microsecond, 0);
    });
  });

  group('ExtendedDate.getMillisecondsIntervalOfMonth', () {
    test('retorna todo o intervalo de um mês com 31 dias', () {
      final (int startMilliseconds, int endMilliseconds) =
          ExtendedDate.getMillisecondsIntervalOfMonth(
        ExtendedDate(2026, 8, 15, 12),
      );

      final ExtendedDate start =
          ExtendedDate.fromMillisecondsSinceEpoch(startMilliseconds);
      final ExtendedDate end =
          ExtendedDate.fromMillisecondsSinceEpoch(endMilliseconds);

      expect(start, ExtendedDate(2026, 8, 1));
      expect(
        end,
        ExtendedDate(2026, 8, 31, 23, 59, 59, 999),
      );
    });

    test('considera o último dia de fevereiro em ano bissexto', () {
      final (int startMilliseconds, int endMilliseconds) =
          ExtendedDate.getMillisecondsIntervalOfMonth(
        ExtendedDate(2024, 2, 10),
      );

      final ExtendedDate start =
          ExtendedDate.fromMillisecondsSinceEpoch(startMilliseconds);
      final ExtendedDate end =
          ExtendedDate.fromMillisecondsSinceEpoch(endMilliseconds);

      expect(start, ExtendedDate(2024, 2, 1));
      expect(
        end,
        ExtendedDate(2024, 2, 29, 23, 59, 59, 999),
      );
    });

    test('termina fevereiro no dia 28 em ano não bissexto', () {
      final (_, int endMilliseconds) =
          ExtendedDate.getMillisecondsIntervalOfMonth(
        ExtendedDate(2026, 2, 10),
      );

      final ExtendedDate end =
          ExtendedDate.fromMillisecondsSinceEpoch(endMilliseconds);

      expect(
        end,
        ExtendedDate(2026, 2, 28, 23, 59, 59, 999),
      );
    });
  });

  group('ExtendedDate.lastDayOfTheMonth', () {
    test('retorna o último milissegundo de um mês com 30 dias', () {
      final ExtendedDate result = ExtendedDate(2026, 4, 15).lastDayOfTheMonth;

      expect(
        result,
        ExtendedDate(2026, 4, 30, 23, 59, 59, 999),
      );
    });

    test('retorna 29 de fevereiro em ano bissexto', () {
      final ExtendedDate result = ExtendedDate(2024, 2, 10).lastDayOfTheMonth;

      expect(
        result,
        ExtendedDate(2024, 2, 29, 23, 59, 59, 999),
      );
    });

    test('trata corretamente a passagem de dezembro para janeiro', () {
      final ExtendedDate result = ExtendedDate(2026, 12, 15).lastDayOfTheMonth;

      expect(
        result,
        ExtendedDate(2026, 12, 31, 23, 59, 59, 999),
      );
    });
  });

  group('ExtendedDate.nextMonth', () {
    test('ajusta dia 31 para o último dia de fevereiro', () {
      final ExtendedDate result = ExtendedDate(2026, 1, 31).nextMonth();

      expect(result, ExtendedDate(2026, 2, 28));
    });

    test('considera fevereiro de ano bissexto', () {
      final ExtendedDate result = ExtendedDate(2024, 1, 31).nextMonth();

      expect(result, ExtendedDate(2024, 2, 29));
    });

    test('trata a passagem de dezembro para janeiro', () {
      final ExtendedDate result = ExtendedDate(2026, 12, 31).nextMonth();

      expect(result, ExtendedDate(2027, 1, 31));
    });

    test('preserva todos os componentes do horário', () {
      final ExtendedDate result = ExtendedDate(
        2026,
        8,
        15,
        10,
        20,
        30,
        456,
        789,
      ).nextMonth();

      expect(
        result,
        ExtendedDate(2026, 9, 15, 10, 20, 30, 456, 789),
      );
    });
  });

  group('ExtendedDate.previousMonth', () {
    test('ajusta dia 31 para o último dia de fevereiro', () {
      final ExtendedDate result = ExtendedDate(2026, 3, 31).previousMonth();

      expect(result, ExtendedDate(2026, 2, 28));
    });

    test('trata a passagem de janeiro para dezembro', () {
      final ExtendedDate result = ExtendedDate(2026, 1, 31).previousMonth();

      expect(result, ExtendedDate(2025, 12, 31));
    });

    test('preserva todos os componentes do horário', () {
      final ExtendedDate result = ExtendedDate(
        2026,
        8,
        15,
        10,
        20,
        30,
        456,
        789,
      ).previousMonth();

      expect(
        result,
        ExtendedDate(2026, 7, 15, 10, 20, 30, 456, 789),
      );
    });
  });

  group('ExtendedDate.nextYear', () {
    test('ajusta 29 de fevereiro para 28 de fevereiro', () {
      final ExtendedDate result = ExtendedDate(2024, 2, 29).nextYear();

      expect(result, ExtendedDate(2025, 2, 28));
    });

    test('preserva todos os componentes do horário', () {
      final ExtendedDate result = ExtendedDate(
        2026,
        8,
        15,
        10,
        20,
        30,
        456,
        789,
      ).nextYear();

      expect(
        result,
        ExtendedDate(2027, 8, 15, 10, 20, 30, 456, 789),
      );
    });
  });

  group('ExtendedDate comparações', () {
    final ExtendedDate earlier = ExtendedDate(2026, 8, 31, 10);
    final ExtendedDate later = ExtendedDate(2026, 8, 31, 11);
    final ExtendedDate same = ExtendedDate(2026, 8, 31, 10);

    test('compara datas com os operadores relacionais', () {
      expect(earlier < later, isTrue);
      expect(earlier <= later, isTrue);
      expect(later > earlier, isTrue);
      expect(later >= earlier, isTrue);
      expect(earlier >= same, isTrue);
      expect(earlier <= same, isTrue);
    });

    test('mantém o comportamento de isBefore e isAfter de DateTime', () {
      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isBefore(same), isFalse);
      expect(earlier.isAfter(same), isFalse);
    });

    test('considera iguais valores que representam o mesmo instante', () {
      expect(earlier, same);
      expect(earlier.hashCode, same.hashCode);
    });

    test('compara corretamente o mesmo instante em UTC e horário local', () {
      final ExtendedDate utc = ExtendedDate.utc(2026, 8, 31, 12);
      final ExtendedDate local =
          ExtendedDate.fromMillisecondsSinceEpoch(utc.millisecondsSinceEpoch);

      expect(local, utc);
      expect(local.hashCode, utc.hashCode);
    });
  });
}
