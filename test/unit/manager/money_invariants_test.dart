import 'package:flutter_test/flutter_test.dart';

int toCents(double value) => (value * 100).round();

void main() {
  test('compara valores monetários após normalização em centavos', () {
    expect(toCents(0.1 + 0.2), 30);
  });

  test('mantém a soma de mil lançamentos de um centavo', () {
    final total = List<double>.filled(1000, 0.01).fold<double>(
      0,
      (sum, value) => sum + value,
    );

    expect(toCents(total), 1000);
  });

  test('normaliza zero negativo', () {
    expect(toCents(-0.0), 0);
  });

  test('preserva valores grandes dentro do limite seguro de centavos', () {
    expect(toCents(999999999.99), 99999999999);
  });
}
